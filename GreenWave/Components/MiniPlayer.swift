//
//  MiniPlayer.swift
//  GreenWave
//
//  Persistent mini-player component
//

import SwiftUI

struct MiniPlayer: View {
    @ObservedObject var audioPlayer = AudioPlayer.shared
    var onTap: () -> Void
    
    var body: some View {
        Group {
            if audioPlayer.currentSong != nil {
                GlassCard(paddingAmount: AppTheme.Spacing.md, cornerRadius: AppTheme.CornerRadius.xl) {
                    HStack(spacing: AppTheme.Spacing.md) {
                        // Artwork
                        AlbumArtwork(song: audioPlayer.currentSong, size: 48, cornerRadius: AppTheme.CornerRadius.md, showShadow: false)
                        
                        // Info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(audioPlayer.currentSong?.displayTitle ?? "")
                                .font(AppTypography.bodyMedium)
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(1)
                            
                            Text(audioPlayer.currentSong?.displayArtist ?? "")
                                .font(AppTypography.captionSmall)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Controls
                        HStack(spacing: AppTheme.Spacing.lg) {
                            Button(action: {
                                AudioPlayer.shared.previous()
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Button(action: {
                                AudioPlayer.shared.togglePlayPause()
                            }) {
                                Image(systemName: audioPlayer.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.primaryAction)
                                    .frame(width: 40, height: 40)
                                    .background(AppColors.primaryAction.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                AudioPlayer.shared.next()
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }
                .onTapGesture(perform: onTap)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Mini Player with Progress

struct MiniPlayerWithProgress: View {
    @ObservedObject var audioPlayer = AudioPlayer.shared
    var onTap: () -> Void
    
    var body: some View {
        Group {
            if audioPlayer.currentSong != nil {
                VStack(spacing: 0) {
                    GlassCard(paddingAmount: AppTheme.Spacing.md, cornerRadius: AppTheme.CornerRadius.xl) {
                        HStack(spacing: AppTheme.Spacing.md) {
                            AlbumArtwork(song: audioPlayer.currentSong, size: 44, cornerRadius: AppTheme.CornerRadius.md, showShadow: false)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(audioPlayer.currentSong?.displayTitle ?? "")
                                    .font(AppTypography.titleSmall)
                                    .foregroundColor(AppColors.textPrimary)
                                    .lineLimit(1)
                                
                                Text(audioPlayer.currentSong?.displayArtist ?? "")
                                    .font(AppTypography.captionSmall)
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                AudioPlayer.shared.togglePlayPause()
                            }) {
                                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(AppColors.primaryAction)
                            }
                        }
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(AppColors.white.opacity(0.2))
                                .frame(height: 3)
                            
                            Capsule()
                                .fill(AppColors.primaryAction)
                                .frame(width: geometry.size.width * CGFloat(audioPlayer.progress / max(audioPlayer.duration, 1)), height: 3)
                        }
                    }
                    .frame(height: 3)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
                .onTapGesture(perform: onTap)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack {
            Spacer()
            
            MiniPlayer(onTap: {})
            
            MiniPlayerWithProgress(onTap: {})
        }
        .padding()
    }
}
