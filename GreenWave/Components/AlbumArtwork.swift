//
//  AlbumArtwork.swift
//  GreenWave
//
//  Reusable album artwork component with caching
//

import SwiftUI
import UIKit

struct AlbumArtwork: View {
    let song: Song?
    var size: CGFloat = 100
    var cornerRadius: CGFloat = AppTheme.CornerRadius.lg
    var showShadow: Bool = true
    
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .shadow(color: showShadow && image != nil ? AppColors.green.opacity(0.3) : .clear, radius: cornerRadius / 2)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(AppColors.white.opacity(0.1), lineWidth: 1)
        }
        .task {
            await loadImage()
        }
    }
    
    // MARK: - Private Views
    
    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.green.opacity(0.5), AppColors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "music.note")
                .font(.system(size: size * 0.4, weight: .light))
                .foregroundColor(AppColors.white.opacity(0.7))
        }
    }
    
    // MARK: - Methods
    
    private func loadImage() async {
        guard let song = song else { return }
        
        // Check cache first
        if let cachedImage = ArtworkManager.shared.getImage(for: song, size: CGSize(width: size, height: size)) {
            self.image = cachedImage
            return
        }
        
        // Load from data
        if let artworkData = song.artworkData,
           let uiImage = UIImage(data: artworkData) {
            let resizedImage = resizeImage(uiImage, to: size)
            self.image = resizedImage
            
            // Cache the image
            ArtworkManager.shared.cacheImage(resizedImage, for: song.id)
        }
    }
    
    private func resizeImage(_ image: UIImage, to size: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: size, height: size), false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: size, height: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }
}

// MARK: - Large Artwork for Player

struct LargeAlbumArtwork: View {
    let song: Song?
    var size: CGFloat = 300
    
    @State private var image: UIImage?
    @State private var dominantColor: Color = AppColors.green
    
    var body: some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xxl))
        .shadow(color: AppColors.green.opacity(0.4), radius: 30, x: 0, y: 10)
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xxl)
                .stroke(AppColors.white.opacity(0.15), lineWidth: 1)
        }
        .task {
            await loadImage()
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            AppColors.glowGradient
            
            Image(systemName: "music.note")
                .font(.system(size: size * 0.3, weight: .ultraLight))
                .foregroundColor(AppColors.white.opacity(0.8))
        }
    }
    
    private func loadImage() async {
        guard let song = song else { return }
        
        if let artworkData = song.artworkData,
           let uiImage = UIImage(data: artworkData) {
            self.image = uiImage
        }
    }
}

// MARK: - Grid Artwork for Albums

struct GridAlbumArtwork: View {
    let album: Album
    var size: CGFloat = 150
    
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let firstSong = album.songs.first,
                      let artworkData = firstSong.artworkData,
                      let uiImage = UIImage(data: artworkData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
        .shadow(color: AppColors.green.opacity(0.2), radius: 10)
        .task {
            await loadImage()
        }
    }
    
    private var placeholderView: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.green.opacity(0.3), AppColors.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            Image(systemName: "music.note")
                .font(.system(size: size * 0.3, weight: .light))
                .foregroundColor(AppColors.white.opacity(0.5))
        }
    }
    
    private func loadImage() async {
        guard let firstSong = album.songs.first,
              let artworkData = firstSong.artworkData,
              let uiImage = UIImage(data: artworkData) else { return }
        
        self.image = uiImage
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack(spacing: 20) {
            AlbumArtwork(song: SampleData.sampleSong, size: 80)
            AlbumArtwork(song: SampleData.sampleSong, size: 120)
            LargeAlbumArtwork(song: SampleData.sampleSong, size: 250)
        }
    }
}

// MARK: - Sample Data for Previews

struct SampleData {
    static let sampleSong = Song(
        id: UUID(),
        title: "Sample Song",
        artist: "Sample Artist",
        album: "Sample Album",
        duration: 180,
        fileURL: ""
    )
}
