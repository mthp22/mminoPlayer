//
//  PlaybackControls.swift
//  MminoPlayer
//  Playback control buttons component (shuffle, repeat, transport).

import SwiftUI

struct PlaybackControls: View {
    @ObservedObject var audioPlayer: AudioPlayer
    
    let showShuffle: Bool
    let showRepeat: Bool
    let buttonSize: CGFloat
    
    init(
        audioPlayer: AudioPlayer,
        showShuffle: Bool = true,
        showRepeat: Bool = true,
        buttonSize: CGFloat = AppTheme.buttonSizeLG
    ) {
        self.audioPlayer = audioPlayer
        self.showShuffle = showShuffle
        self.showRepeat = showRepeat
        self.buttonSize = buttonSize
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacingMD) {
            // Shuffle and Repeat row
            if showShuffle || showRepeat {
                HStack(spacing: AppTheme.spacingXL) {
                    if showShuffle {
                        Button(action: { audioPlayer.shuffleEnabled.toggle() }) {
                            Image(systemName: "shuffle")
                                .font(.system(size: buttonSize * 0.4))
                                .foregroundColor(audioPlayer.shuffleEnabled ? AppColors.lime : AppColors.grayLight)
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel("Shuffle")
                        .accessibilityValue(audioPlayer.shuffleEnabled ? "On" : "Off")
                    }
                    
                    Spacer()
                    
                    if showRepeat {
                        Button(action: { audioPlayer.repeatMode = audioPlayer.repeatMode.next() }) {
                            Image(systemName: audioPlayer.repeatMode.icon)
                                .font(.system(size: buttonSize * 0.4))
                                .foregroundColor(audioPlayer.repeatMode != .off ? AppColors.lime : AppColors.grayLight)
                                .frame(width: 44, height: 44)
                        }
                        .overlay {
                            if audioPlayer.repeatMode == .one {
                                Text("1")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppColors.background)
                                    .offset(x: buttonSize * 0.15, y: -buttonSize * 0.15)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel("Repeat")
                        .accessibilityValue(audioPlayer.repeatMode.description)
                    }
                }
                .padding(.horizontal, AppTheme.spacingLG)
            }
            
            // Main playback controls
            HStack(spacing: AppTheme.spacingXL) {
                Button(action: { audioPlayer.skipToPrevious() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: buttonSize * 0.5))
                        .foregroundColor(AppColors.white)
                        .frame(width: buttonSize, height: buttonSize)
                }
                .accessibilityLabel("Previous track")

                Button(action: { audioPlayer.togglePlayPause() }) {
                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: buttonSize * 1.2))
                        .foregroundColor(AppColors.lime)
                        .frame(width: buttonSize * 1.2, height: buttonSize * 1.2)
                }
                .accessibilityLabel(audioPlayer.isPlaying ? "Pause" : "Play")

                Button(action: { audioPlayer.skipToNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: buttonSize * 0.5))
                        .foregroundColor(AppColors.white)
                        .frame(width: buttonSize, height: buttonSize)
                }
                .accessibilityLabel("Next track")
            }
        }
    }
}

#Preview {
    PlaybackControls(audioPlayer: AudioPlayer.shared)
        .padding()
        .background(AppColors.background)
}
