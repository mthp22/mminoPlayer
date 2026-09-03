//
//  MiniPlayer.swift
//  MminoPlayer
//
//  Persistent mini-player component

import SwiftUI

struct MiniPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    let onTap: () -> Void
    
    @State private var isDragging = false
    
    var body: some View {
        GlassCard(padding: AppTheme.spacingSM, cornerRadius: AppTheme.cornerRadiusXL) {
            HStack(spacing: AppTheme.spacingMD) {
                // Artwork
                if let song = audioPlayer.currentSong {
                    AlbumArtwork(
                        artworkData: song.artworkData,
                        size: AppTheme.artworkSizeMini,
                        cornerRadius: AppTheme.cornerRadiusSM
                    )
                    
                    // Info and progress
                    VStack(alignment: .leading, spacing: AppTheme.spacingXXS) {
                        Text(song.displayTitle)
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.white)
                            .lineLimit(1)
                        
                        Text(song.displayArtist)
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.grayLight)
                            .lineLimit(1)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.grayDark)
                                    .frame(height: 4)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.lime)
                                    .frame(width: geometry.size.width * audioPlayer.progress, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: AppTheme.spacingMD) {
                        Button(action: {
                            audioPlayer.skipToPrevious()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.white)
                        }
                        
                        Button(action: {
                            if audioPlayer.isPlaying {
                                audioPlayer.pause()
                            } else {
                                audioPlayer.resume()
                            }
                        }) {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.lime)
                        }
                    }
                } else {
                    Text("No song playing")
                        .foregroundColor(AppColors.grayLight)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .shadow(color: AppColors.green.opacity(0.2), radius: 10, y: -2)
    }
}

#Preview {
    VStack {
        Spacer()
        
        MiniPlayer(
            audioPlayer: AudioPlayer.shared,
            onTap: {}
        )
        .padding(.horizontal)
        .padding(.bottom, AppTheme.spacingMD)
    }
    .background(AppColors.background)
}
