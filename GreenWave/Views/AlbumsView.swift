//
//  AlbumsView.swift
//  GreenWave
//
//  Grid of albums in the library
//

import SwiftUI

struct AlbumsView: View {
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    private let columns = [
        GridItem(.adaptive(minimum: 160, maximum: 200), spacing: AppTheme.Spacing.lg)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if musicLibrary.albums.isEmpty {
                    EmptyStateView(
                        icon: "music.note.list",
                        title: "No albums",
                        message: "Albums from your imported music will appear here."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
                            ForEach(musicLibrary.albums) { album in
                                NavigationLink(destination: AlbumDetailView(album: album)) {
                                    AlbumCard(album: album)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Albums")
        }
    }
}

// MARK: - Album Detail View

struct AlbumDetailView: View {
    let album: Album
    @EnvironmentObject var audioPlayer: AudioPlayer
    @EnvironmentObject var musicLibrary: MusicLibrary
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.xl) {
                // Album Artwork
                GridAlbumArtwork(album: album, size: 250)
                
                // Album Info
                VStack(spacing: AppTheme.Spacing.sm) {
                    Text(album.title)
                        .font(AppTypography.headlineLarge)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(album.displayArtist)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(album.songCount) Songs • \(album.formattedDuration)")
                        .font(AppTypography.captionSmall)
                        .foregroundColor(AppColors.textTertiary)
                }
                
                // Play Buttons
                HStack(spacing: AppTheme.Spacing.lg) {
                    Button(action: { playAlbum() }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Play")
                        }
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(AppColors.background)
                        .padding(.horizontal, AppTheme.Spacing.xxl)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppColors.primaryAction)
                        .clipShape(Capsule())
                    }
                    
                    Button(action: { shuffleAlbum() }) {
                        HStack {
                            Image(systemName: "shuffle")
                            Text("Shuffle")
                        }
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(AppColors.primaryAction)
                        .padding(.horizontal, AppTheme.Spacing.xxl)
                        .padding(.vertical, AppTheme.Spacing.md)
                        .background(AppColors.primaryAction.opacity(0.2))
                        .clipShape(Capsule())
                    }
                }
                
                // Track List
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                        CompactSongRow(
                            song: song,
                            index: index,
                            onTap: { playTrack(at: index) }
                        )
                        
                        if index < album.songs.count - 1 {
                            Divider()
                                .background(AppColors.divider)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func playAlbum() {
        audioPlayer.play(album.songs.first!, inQueue: album.songs)
    }
    
    private func shuffleAlbum() {
        let shuffled = album.songs.shuffled()
        audioPlayer.play(shuffled.first!, inQueue: shuffled)
    }
    
    private func playTrack(at index: Int) {
        let remainingTracks = Array(album.songs.dropFirst(index + 1))
        audioPlayer.play(album.songs[index], inQueue: remainingTracks)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        AlbumsView()
            .environmentObject(MusicLibrary.shared)
            .environmentObject(AudioPlayer.shared)
    }
}
