//
//  AlbumArtwork.swift
//  MminoPlayer
//
//  Artwork display component backed by the shared ArtworkManager cache.

import SwiftUI
import UIKit

struct AlbumArtwork: View {
    let artworkData: Data?
    let artworkID: String
    let size: CGFloat
    let cornerRadius: CGFloat
    let showPlaceholder: Bool

    init(
        artworkData: Data?,
        artworkID: String = "",
        size: CGFloat = AppTheme.artworkSizeMedium,
        cornerRadius: CGFloat = AppTheme.cornerRadiusLG,
        showPlaceholder: Bool = true
    ) {
        self.artworkData = artworkData
        self.artworkID = artworkID
        self.size = size
        self.cornerRadius = cornerRadius
        self.showPlaceholder = showPlaceholder
    }
    
    var body: some View {
        ZStack {
            if let uiImage = resolvedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
            } else if showPlaceholder {
                placeholderView
                    .frame(width: size, height: size)
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
        .accessibilityHidden(true)
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

            Image(systemName: "music.note")
                .font(.system(size: size * 0.35))
                .fontWeight(.light)
                .foregroundColor(AppColors.grayMedium)
        }
    }

    private var resolvedImage: UIImage? {
        guard let artworkData else { return nil }
        let key = artworkID.isEmpty ? "anonymous-\(artworkData.count)" : artworkID
        return ArtworkManager.shared.image(forID: key, data: artworkData)
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
