//
//  SongRow.swift
//  MminoPlayer
//
//  Song list row component

import SwiftUI

struct SongRow: View {
    let song: Song
    let isPlaying: Bool
    let showAlbum: Bool
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    
    init(
        song: Song,
        isPlaying: Bool = false,
        showAlbum: Bool = true,
        onTap: @escaping () -> Void,
        onFavoriteToggle: @escaping () -> Void
    ) {
        self.song = song
        self.isPlaying = isPlaying
        self.showAlbum = showAlbum
        self.onTap = onTap
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        GlassCard(
            padding: AppTheme.spacingSM,
            cornerRadius: AppTheme.cornerRadiusMD
        ) {
            HStack(spacing: AppTheme.spacingMD) {
                // Artwork
                AlbumArtwork(
                    artworkData: song.artworkData,
                    size: AppTheme.artworkSizeSmall,
                    cornerRadius: AppTheme.cornerRadiusSM
                )
                
                // Info
                VStack(alignment: .leading, spacing: AppTheme.spacingXXS) {
                    Text(song.displayTitle)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(isPlaying ? AppColors.lime : AppColors.white)
                        .lineLimit(1)
                    
                    if showAlbum {
                        Text(song.displayArtist)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.grayLight)
                            .lineLimit(1)
                    } else {
                        Text(song.displayAlbum)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.grayLight)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // Duration and controls
                HStack(spacing: AppTheme.spacingMD) {
                    Text(song.formattedDuration)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.grayMedium)
                        .monospacedDigit()
                    
                    Button(action: onFavoriteToggle) {
                        Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(song.isFavorite ? AppColors.lime : AppColors.grayMedium)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.grayMedium)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    VStack(spacing: AppTheme.spacingSM) {
        SongRow(
            song: Song(
                title: "Example Song",
                artist: "Artist Name",
                album: "Album Title",
                duration: 234.5,
                fileURL: "file://example.mp3"
            ),
            isPlaying: false,
            onTap: {},
            onFavoriteToggle: {}
        )
        
        SongRow(
            song: Song(
                title: "Another Song",
                artist: "Another Artist",
                album: "Another Album",
                duration: 189.0,
                fileURL: "file://example2.mp3",
                isFavorite: true
            ),
            isPlaying: true,
            onTap: {},
            onFavoriteToggle: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
