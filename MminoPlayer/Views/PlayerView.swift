//
//  PlayerView.swift
//  MminoPlayer
//
//  Full-screen player view

import SwiftUI

struct PlayerView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Environment(\.dismiss) private var dismiss
    @StateObject private var library = MusicLibrary.shared
    
    @State private var showingQueue = false
    @State private var isDraggingProgress = false
    
    var body: some View {
        ZStack {
            // Background with blur and gradient
            backgroundView
            
            VStack(spacing: AppTheme.spacingLG) {
                // Header
                headerView
                
                Spacer()
                
                // Album artwork
                AlbumArtwork(
                    artworkData: audioPlayer.currentSong?.artworkData,
                    size: AppTheme.artworkSizeXLarge,
                    cornerRadius: AppTheme.cornerRadiusXL
                )
                .shadow(color: AppColors.green.opacity(0.3), radius: 30, y: 10)
                
                Spacer()
                
                // Song info
                if let song = audioPlayer.currentSong {
                    VStack(spacing: AppTheme.spacingXXS) {
                        Text(song.displayTitle)
                            .font(AppTypography.displaySmall)
                            .foregroundColor(AppColors.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                        
                        Text(song.displayArtist)
                            .font(AppTypography.headlineMedium)
                            .foregroundColor(AppColors.grayLight)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Progress slider
                    progressView
                    
                    Spacer()
                    
                    // Controls
                    PlaybackControls(
                        audioPlayer: audioPlayer,
                        buttonSize: AppTheme.buttonSizeXL
                    )
                    
                    // Bottom row
                    bottomRow(song: song)
                } else {
                    Text("No song playing")
                        .foregroundColor(AppColors.grayLight)
                }
                
                Spacer(minLength: 50)
            }
            .padding(.horizontal, AppTheme.spacingLG)
            .padding(.top, AppTheme.spacingMD)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Background
    
    private var backgroundView: some View {
        ZStack {
            AppColors.background
            
            // Subtle green glow at top
            RadialGradient(
                colors: [AppColors.green.opacity(0.15), .clear],
                center: .top,
                startRadius: 100,
                endRadius: 400
            )
            
            // Blur effect
            Color.black.opacity(0.2)
                .blur(radius: 50)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.white)
                    .frame(width: 44, height: 44)
                    .background(AppColors.glassBackground)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Button(action: { showingQueue = true }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.white)
                    .frame(width: 44, height: 44)
                    .background(AppColors.glassBackground)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Progress
    
    private var progressView: some View {
        VStack(spacing: AppTheme.spacingSM) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.grayDark)
                        .frame(height: AppTheme.progressHeight)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 2)
                        .fill(AppColors.lime)
                        .frame(width: min(geometry.size.width * audioPlayer.progress, geometry.size.width), height: AppTheme.progressActiveHeight)
                        .shadow(color: AppColors.lime.opacity(0.5), radius: 4)
                    
                    // Thumb (when dragging)
                    if isDraggingProgress {
                        Circle()
                            .fill(AppColors.lime)
                            .frame(width: 16, height: 16)
                            .offset(x: geometry.size.width * audioPlayer.progress - 8)
                            .shadow(color: .black.opacity(0.3), radius: 4)
                    }
                    
                    // Invisible drag area
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isDraggingProgress = true
                                let newProgress = min(max(value.location.x / geometry.size.width, 0), 1)
                                audioPlayer.seek(to: newProgress * audioPlayer.duration)
                            }
                            .onEnded { _ in
                                isDraggingProgress = false
                            }
                        )
                }
            }
            .frame(height: 20)
            
            HStack {
                Text(formatTime(audioPlayer.progress * audioPlayer.duration))
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.grayMedium)
                    .monospacedDigit()
                
                Spacer()
                
                Text(formatTime(audioPlayer.duration))
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.grayMedium)
                    .monospacedDigit()
            }
        }
        .padding(.horizontal, AppTheme.spacingSM)
    }
    
    // MARK: - Bottom Row
    
    @ViewBuilder
    private func bottomRow(song: Song) -> some View {
        HStack(spacing: AppTheme.spacingXL) {
            // Favorite
            Button(action: {
                library.toggleFavorite(song)
            }) {
                Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(song.isFavorite ? AppColors.lime : AppColors.grayLight)
            }
            
            // AirPlay / More options placeholder
            Button(action: {}) {
                Image(systemName: "airplayaudio")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.grayLight)
            }
            
            // Share
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.grayLight)
            }
        }
        .padding(.bottom, AppTheme.spacingMD)
    }
    
    // MARK: - Helpers
    
    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else {
            return "0:00"
        }
        
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    PlayerView(audioPlayer: AudioPlayer.shared)
}
