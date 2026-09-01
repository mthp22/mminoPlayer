//
//  SongRow.swift
//  GreenWave
//
//  Reusable song row component for lists
//

import SwiftUI

struct SongRow: View {
    let song: Song
    var showAlbum: Bool = false
    var onTap: () -> Void
    var onFavoriteToggle: () -> Void
    var onMore: () -> Void
    
    @ObservedObject private var audioPlayer = AudioPlayer.shared
    
    var isPlaying: Bool {
        audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Artwork or Playing Indicator
            if isPlaying {
                Image(systemName: "waveform")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryAction)
                    .frame(width: 44, height: 44)
                    .background(AppColors.primaryAction.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.md))
            } else {
                AlbumArtwork(song: song, size: 44, cornerRadius: AppTheme.CornerRadius.md, showShadow: false)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(song.displayTitle)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(isPlaying ? AppColors.primaryAction : AppColors.textPrimary)
                    .lineLimit(1)
                
                if showAlbum && !song.displayAlbum.isEmpty {
                    Text(song.displayAlbum)
                        .font(AppTypography.captionSmall)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                } else {
                    Text(song.displayArtist)
                        .font(AppTypography.captionSmall)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Duration
            Text(song.formattedDuration)
                .font(AppTypography.captionSmall)
                .foregroundColor(AppColors.textTertiary)
                .monospacedDigit()
            
            // Favorite button
            Button(action: onFavoriteToggle) {
                Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 16))
                    .foregroundColor(song.isFavorite ? AppColors.primaryAction : AppColors.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // More button
            Button(action: onMore) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Compact Song Row

struct CompactSongRow: View {
    let song: Song
    var index: Int = 0
    var onTap: () -> Void
    
    @ObservedObject private var audioPlayer = AudioPlayer.shared
    
    var isPlaying: Bool {
        audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying
    }
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            // Index or Playing Indicator
            if isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.primaryAction)
                    .frame(width: 24, height: 24)
            } else {
                Text("\(index + 1)")
                    .font(AppTypography.captionSmall)
                    .foregroundColor(AppColors.textTertiary)
                    .frame(width: 24, height: 24)
            }
            
            AlbumArtwork(song: song, size: 40, cornerRadius: AppTheme.CornerRadius.sm, showShadow: false)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(song.displayTitle)
                    .font(AppTypography.bodySmall)
                    .foregroundColor(isPlaying ? AppColors.primaryAction : AppColors.textPrimary)
                    .lineLimit(1)
                
                Text(song.displayArtist)
                    .font(AppTypography.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(song.formattedDuration)
                .font(AppTypography.captionSmall)
                .foregroundColor(AppColors.textTertiary)
                .monospacedDigit()
        }
        .padding(.vertical, AppTheme.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack(spacing: 8) {
            SongRow(
                song: SampleData.sampleSong,
                showAlbum: true,
                onTap: {},
                onFavoriteToggle: {},
                onMore: {}
            )
            
            Divider()
            
            CompactSongRow(
                song: SampleData.sampleSong,
                index: 1,
                onTap: {}
            )
        }
        .padding()
    }
}
