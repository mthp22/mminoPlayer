//
//  PlaybackControls.swift
//  GreenWave
//
//  Reusable playback controls component
//

import SwiftUI

struct PlaybackControls: View {
    @ObservedObject var audioPlayer = AudioPlayer.shared
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Progress slider
            progressSection
            
            // Main controls
            mainControlsSection
            
            // Secondary controls (shuffle, repeat)
            secondaryControlsSection
        }
    }
    
    // MARK: - Sections
    
    private var progressSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Slider(
                value: Binding(
                    get: { audioPlayer.progress },
                    set: { newValue in
                        audioPlayer.seek(to: newValue)
                    }
                ),
                in: 0...max(audioPlayer.duration, 1),
                minimumValueLabel: Text(formatTime(audioPlayer.progress)),
                maximumValueLabel: Text(formatTime(audioPlayer.duration))
            )
            .tint(AppColors.primaryAction)
            
            HStack {
                Text(formatTime(audioPlayer.progress))
                    .font(AppTypography.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
                    .monospacedDigit()
                
                Spacer()
                
                Text(formatTime(audioPlayer.duration))
                    .font(AppTypography.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, AppTheme.Spacing.xl)
    }
    
    private var mainControlsSection: some View {
        HStack(spacing: AppTheme.Spacing.xxl) {
            // Previous
            Button(action: {
                audioPlayer.previous()
            }) {
                Image(systemName: "backward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.textPrimary)
            }
            
            // Play/Pause
            Button(action: {
                audioPlayer.togglePlayPause()
            }) {
                Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(AppColors.primaryAction)
            }
            
            // Next
            Button(action: {
                audioPlayer.next()
            }) {
                Image(systemName: "forward.fill")
                    .font(.system(size: 28))
                    .foregroundColor(AppColors.textPrimary)
            }
        }
    }
    
    private var secondaryControlsSection: some View {
        HStack(spacing: AppTheme.Spacing.xxl) {
            // Shuffle
            Button(action: {
                withAnimation(AppTheme.Animation.spring) {
                    audioPlayer.shuffleEnabled.toggle()
                }
            }) {
                Image(systemName: "shuffle")
                    .font(.system(size: 20))
                    .foregroundColor(audioPlayer.shuffleEnabled ? AppColors.primaryAction : AppColors.textTertiary)
            }
            
            // Repeat
            Button(action: {
                withAnimation(AppTheme.Animation.spring) {
                    audioPlayer.repeatMode = audioPlayer.repeatMode.next
                }
            }) {
                Image(systemName: audioPlayer.repeatMode.icon)
                    .font(.system(size: 20))
                    .foregroundColor(audioPlayer.repeatMode != .off ? AppColors.primaryAction : AppColors.textTertiary)
            }
            .overlay {
                if audioPlayer.repeatMode == .one {
                    Text("1")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.primaryAction)
                        .offset(x: 8, y: 8)
                }
            }
            
            // Queue
            NavigationLink(destination: QueueView()) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundColor(!audioPlayer.queue.isEmpty ? AppColors.primaryAction : AppColors.textTertiary)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack {
            Spacer()
            
            PlaybackControls()
            
            Spacer()
        }
    }
}
