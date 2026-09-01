//
//  PlayerView.swift
//  GreenWave
//
//  Full-screen player view
//

import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    @EnvironmentObject var musicLibrary: MusicLibrary
    @Environment(\.dismiss) var dismiss
    @State private var showingQueue = false
    @State private var showingMoreOptions = false
    
    var body: some View {
        ZStack {
            // Background with blur
            backgroundLayer
            
            VStack(spacing: AppTheme.Spacing.xxl) {
                // Header
                headerSection
                
                Spacer()
                
                // Album Artwork
                LargeAlbumArtwork(song: audioPlayer.currentSong, size: 320)
                
                // Song Info
                songInfoSection
                
                // Playback Controls
                PlaybackControls()
                
                Spacer()
                
                // Bottom Actions
                bottomActionsSection
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Layers
    
    private var backgroundLayer: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            // Subtle artwork-based gradient
            if let _ = audioPlayer.currentSong?.artworkData {
                RadialGradient(
                    colors: [AppColors.green.opacity(0.15), .clear],
                    center: .top,
                    startRadius: 100,
                    endRadius: 400
                )
            }
            
            // Glass overlay
            Color.black.opacity(0.2).ignoresSafeArea()
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppColors.white.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            Text("Now Playing")
                .font(AppTypography.titleMedium)
                .foregroundColor(AppColors.textSecondary)
            
            Spacer()
            
            Button(action: { showingMoreOptions = true }) {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.textPrimary)
                    .frame(width: 44, height: 44)
            }
        }
    }
    
    private var songInfoSection: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Text(audioPlayer.currentSong?.displayTitle ?? "Unknown")
                .font(AppTypography.headlineLarge)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text(audioPlayer.currentSong?.displayArtist ?? "Unknown Artist")
                .font(AppTypography.bodyLarge)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
            
            if let album = audioPlayer.currentSong?.displayAlbum, !album.isEmpty {
                Text(album)
                    .font(AppTypography.captionSmall)
                    .foregroundColor(AppColors.textTertiary)
                    .lineLimit(1)
            }
        }
    }
    
    private var bottomActionsSection: some View {
        HStack(spacing: AppTheme.Spacing.xxl) {
            // Favorite
            Button(action: { toggleFavorite() }) {
                Image(systemName: audioPlayer.currentSong?.isFavorite ?? false ? "heart.fill" : "heart")
                    .font(.system(size: 24))
                    .foregroundColor(audioPlayer.currentSong?.isFavorite ?? false ? AppColors.primaryAction : AppColors.textSecondary)
            }
            
            // AirPlay
            Button(action: {}) {
                Image(systemName: "airplayaudio")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // Queue
            Button(action: { showingQueue = true }) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 24))
                    .foregroundColor(!audioPlayer.queue.isEmpty ? AppColors.primaryAction : AppColors.textSecondary)
            }
            .overlay {
                if !audioPlayer.queue.isEmpty {
                    Text("\(audioPlayer.queue.count)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.background)
                        .frame(width: 18, height: 18)
                        .background(AppColors.primaryAction)
                        .clipShape(Circle())
                        .offset(x: 12, y: -12)
                }
            }
            
            // Sleep Timer (placeholder)
            Button(action: {}) {
                Image(systemName: "timer")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.bottom, AppTheme.Spacing.lg)
    }
    
    // MARK: - Actions
    
    private func toggleFavorite() {
        guard let song = audioPlayer.currentSong else { return }
        musicLibrary.toggleFavorite(song)
    }
}

// MARK: - Queue Sheet

struct QueueSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var audioPlayer: AudioPlayer
    @EnvironmentObject var musicLibrary: MusicLibrary
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                Group {
                    if audioPlayer.queue.isEmpty {
                        EmptyStateView(
                            icon: "list.bullet",
                            title: "Queue is empty",
                            message: "Add songs to the queue to play them next."
                        )
                    } else {
                        List {
                            ForEach(Array(audioPlayer.queue.enumerated()), id: \.element.id) { index, song in
                                HStack(spacing: AppTheme.Spacing.md) {
                                    Text("\(index + 1)")
                                        .font(AppTypography.captionSmall)
                                        .foregroundColor(AppColors.textTertiary)
                                        .frame(width: 24)
                                    
                                    AlbumArtwork(song: song, size: 44, cornerRadius: AppTheme.CornerRadius.md, showShadow: false)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(song.displayTitle)
                                            .font(AppTypography.bodyMedium)
                                            .foregroundColor(AppColors.textPrimary)
                                            .lineLimit(1)
                                        
                                        Text(song.displayArtist)
                                            .font(AppTypography.captionSmall)
                                            .foregroundColor(AppColors.textSecondary)
                                            .lineLimit(1)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        audioPlayer.removeFromQueue(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(AppColors.textTertiary)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.vertical, AppTheme.Spacing.sm)
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle("Up Next")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        audioPlayer.clearQueue()
                    }
                    .foregroundColor(AppColors.primaryAction)
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }
}

#Preview {
    PlayerView()
        .environmentObject(AudioPlayer.shared)
        .environmentObject(MusicLibrary.shared)
}
