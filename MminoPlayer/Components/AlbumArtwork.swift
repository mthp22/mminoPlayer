//
//  AlbumArtwork.swift
//  MminoPlayer
//
//  Artwork display component with caching

import SwiftUI

struct AlbumArtwork: View {
    let artworkData: Data?
    let size: CGFloat
    let cornerRadius: CGFloat
    let showPlaceholder: Bool
    
    @State private var image: UIImage?
    
    init(
        artworkData: Data?,
        size: CGFloat = AppTheme.artworkSizeMedium,
        cornerRadius: CGFloat = AppTheme.cornerRadiusLG,
        showPlaceholder: Bool = true
    ) {
        self.artworkData = artworkData
        self.size = size
        self.cornerRadius = cornerRadius
        self.showPlaceholder = showPlaceholder
    }
    
    var body: some View {
        ZStack {
            if let imageData = artworkData, let uiImage = loadImage(from: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if showPlaceholder {
                placeholderView
            }
            
            // Subtle gradient overlay for depth
            LinearGradient(
                colors: [
                    Color.white.opacity(0.1),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }
    
    private var placeholderView: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    AppColors.surfaceElevated,
                    AppColors.grayDark
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Music note icon
            Image(systemName: "music.note")
                .font(.system(size: size * 0.35))
                .fontWeight(.light)
                .foregroundColor(AppColors.grayMedium)
        }
    }
    
    private func loadImage(from data: Data) -> UIImage? {
        // Cache the loaded image to avoid repeated decoding
        if image == nil {
            image = UIImage(data: data)
        }
        return image
    }
}

// MARK: - Artwork cache manager
final class ArtworkCacheManager {
    static let shared = ArtworkCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private let maxCacheSize: Int = 100 * 1024 * 1024 // 100MB
    
    private init() {
        cache.countLimit = 500
        cache.totalCostLimit = maxCacheSize
    }
    
    func image(for songID: String, data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        
        let key = songID as NSString
        
        // Check cache first
        if let cachedImage = cache.object(forKey: key) {
            return cachedImage
        }
        
        // Load and cache
        if let image = UIImage(data: data) {
            cache.setObject(image, forKey: key, cost: data.count)
            return image
        }
        
        return nil
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

#Preview {
    VStack(spacing: AppTheme.spacingLG) {
        AlbumArtwork(artworkData: nil, size: 120)
        AlbumArtwork(artworkData: nil, size: 200, cornerRadius: 24)
    }
    .padding()
    .background(AppColors.background)
}
