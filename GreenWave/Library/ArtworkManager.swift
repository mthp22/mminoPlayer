//
//  ArtworkManager.swift
//  GreenWave
//
//  Manages album artwork caching and retrieval
//

import Foundation
import SwiftUI
import UIKit

struct ArtworkManager {
    static let shared = ArtworkManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    
    private var artworkDirectory: URL {
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let artworkURL = cachesURL.appendingPathComponent("Artwork", isDirectory: true)
        
        try? fileManager.createDirectory(at: artworkURL, withIntermediateDirectories: true)
        
        return artworkURL
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    func getImage(for song: Song, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        // Check memory cache first
        let cacheKey = song.id.uuidString as NSString
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check disk cache
        if let artworkData = song.artworkData,
           let image = UIImage(data: artworkData) {
            cache.setObject(image, forKey: cacheKey)
            return resizeImage(image, to: size)
        }
        
        // Generate placeholder
        return generatePlaceholderArtwork()
    }
    
    func getResizedImage(from data: Data?, size: CGSize = CGSize(width: 300, height: 300)) -> UIImage? {
        guard let data = data,
              let image = UIImage(data: data) else {
            return nil
        }
        
        return resizeImage(image, to: size)
    }
    
    func clearCache() {
        cache.removeAllObjects()
        
        try? fileManager.removeItem(at: artworkDirectory)
        try? fileManager.createDirectory(at: artworkDirectory, withIntermediateDirectories: true)
    }
    
    // MARK: - Private Methods
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    private func generatePlaceholderArtwork() -> UIImage {
        let size = CGSize(width: 300, height: 300)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        // Background gradient
        let colors = [
            AppColors.green.cgColor,
            AppColors.surface.cgColor
        ]
        let gradient = CGGradient(colorsSpace: nil, colors: colors as CFArray, locations: [0, 1])
        
        context.drawLinearGradient(
            gradient!,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size.width, y: size.height),
            options: []
        )
        
        // Music note icon
        let noteRect = CGRect(x: size.width * 0.25, y: size.height * 0.25, width: size.width * 0.5, height: size.height * 0.5)
        let notePath = UIBezierPath()
        
        // Draw a simple music note shape
        let centerX = noteRect.midX
        let centerY = noteRect.midY
        let radius = noteRect.width * 0.15
        
        // Note head (circle)
        let headPath = UIBezierPath(ovalIn: CGRect(x: centerX - radius, y: centerY + radius, width: radius * 2, height: radius * 2))
        
        // Note stem
        let stemPath = UIBezierPath()
        stemPath.move(to: CGPoint(x: centerX + radius, y: centerY + radius))
        stemPath.addLine(to: CGPoint(x: centerX + radius, y: centerY - radius * 2))
        stemPath.lineWidth = radius * 0.4
        UIColor.white.setStroke()
        stemPath.stroke()
        
        // Draw note head
        UIColor.white.setFill()
        headPath.fill()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}

// MARK: - Image Cache Helper

extension ArtworkManager {
    func cacheImage(_ image: UIImage, for songId: UUID) {
        let cacheKey = songId.uuidString as NSString
        cache.setObject(image, forKey: cacheKey)
    }
}
