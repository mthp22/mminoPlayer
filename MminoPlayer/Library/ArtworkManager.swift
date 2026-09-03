//
//  ArtworkManager.swift
//  MminoPlayer
//
//  Manages artwork caching and retrieval

import Foundation
import SwiftUI
import UIKit

final class ArtworkManager {
    static let shared = ArtworkManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    private var cacheDirectory: URL? {
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths.first?.appendingPathComponent("ArtworkCache", isDirectory: true)
    }
    
    private init() {
        cache.countLimit = 500
        cache.totalCostLimit = 100 * 1024 * 1024 // 100MB
        
        // Ensure cache directory exists
        if let cacheDir = cacheDirectory {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }
    
    func image(for song: Song, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        // Check memory cache first
        let cacheKey = song.id.uuidString as NSString
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Load from data
        guard let data = song.artworkData else {
            return nil
        }
        
        if let image = UIImage(data: data) {
            // Cache it
            cache.setObject(image, forKey: cacheKey, cost: data.count)
            return image
        }
        
        return nil
    }
    
    func placeholderImage(size: CGFloat = 200) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        
        return renderer.image { context in
            // Background gradient
            let colors = [
                AppColors.surfaceElevated.cgColor,
                AppColors.grayDark.cgColor
            ]
            
            let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: [0, 1])!
            context.fill(CGRect(x: 0, y: 0, width: size, height: size), blendMode: .normal, alpha: 1.0)
            
            // Draw music note
            let image = UIImage(systemName: "music.note")?
                .withTintColor(AppColors.grayMedium, renderingMode: .alwaysOriginal)
            
            let rect = CGRect(x: (size - 60) / 2, y: (size - 60) / 2, width: 60, height: 60)
            image?.draw(in: rect)
        }
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        if let cacheDir = cacheDirectory {
            try? fileManager.removeItem(at: cacheDir)
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }
    
    func preloadImages(for songs: [Song]) {
        DispatchQueue.global(qos: .userInitiated).async {
            for song in songs {
                _ = self.image(for: song)
            }
        }
    }
}
