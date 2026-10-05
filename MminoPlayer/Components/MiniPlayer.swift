//
//  MiniPlayer.swift
//  MminoPlayer
//
//  Persistent mini-player
//  AudioPlayer state.

import SwiftUI

struct MiniPlayer: View {
    @ObservedObject var audioPlayer: AudioPlayer
    let onTap: () -> Void

    var body: some View {
        GlassCard(
            padding: AppTheme.spacingSM,
            cornerRadius: AppTheme.cornerRadiusXL
        ) {
            HStack(spacing: AppTheme.spacingMD) {
                if let song = audioPlayer.currentSong {
                    // Artwork
                    AlbumArtwork(
                        artworkData: song.artworkData,
                        artworkID: song.id.uuidString,
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
                                    .frame(
                                        width: geometry.size.width * min(max(audioPlayer.progress, 0), 1),
                                        height: 4
                                    )
                            }
                        }
                        .frame(height: 4)
                        .accessibilityElement()
                        .accessibilityLabel("Playback progress")
                        .accessibilityValue(
                            "\(Song.formatDuration(audioPlayer.currentTime)) of \(Song.formatDuration(audioPlayer.duration))"
                        )
                    }

                    Spacer(minLength: AppTheme.spacingXS)

                    // Controls
                    HStack(spacing: AppTheme.spacingMD) {
                        Button(action: { audioPlayer.skipToPrevious() }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppColors.white)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Previous track")

                        Button(action: { audioPlayer.togglePlayPause() }) {
                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(AppColors.lime)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel(audioPlayer.isPlaying ? "Pause" : "Play")
                    }
                } else {
                    Text("No song playing")
                        .foregroundColor(AppColors.grayLight)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .shadow(color: AppColors.green.opacity(0.2), radius: 10, y: -2)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("MiniPlayer")
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
