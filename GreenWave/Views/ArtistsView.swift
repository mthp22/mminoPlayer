//
//  ArtistsView.swift
//  GreenWave
//
//  List of artists in the library
//

import SwiftUI

struct ArtistsView: View {
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 150), spacing: AppTheme.Spacing.lg)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if musicLibrary.artists.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No artists",
                        message: "Artists from your imported music will appear here."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: AppTheme.Spacing.xl) {
                            ForEach(musicLibrary.artists) { artist in
                                NavigationLink(destination: ArtistDetailView(artist: artist)) {
                                    ArtistCard(artist: artist)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Artists")
        }
    }
}

// MARK: - Artist Detail View

struct ArtistDetailView: View {
    let artist: Artist
    @EnvironmentObject var audioPlayer: AudioPlayer
    @EnvironmentObject var musicLibrary: MusicLibrary
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                // Artist Header
                HStack(spacing: AppTheme.Spacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppColors.surface)
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text(artist.name)
                            .font(AppTypography.headlineLarge)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("\(artist.songCount) Songs • \(artist.albumCount) Albums")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // Songs Section
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    Text("Songs")
                        .font(AppTypography.headlineMedium)
                        .foregroundColor(AppColors.textPrimary)
                    
                    ForEach(artist.songs.sorted()) { song in
                        SongRow(
                            song: song,
                            showAlbum: true,
                            onTap: { playSong(song) },
                            onFavoriteToggle: { toggleFavorite(song) },
                            onMore: {}
                        )
                        
                        Divider()
                            .background(AppColors.divider)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(artist.name)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func playSong(_ song: Song) {
        audioPlayer.play(song, inQueue: artist.songs.sorted())
    }
    
    private func toggleFavorite(_ song: Song) {
        musicLibrary.toggleFavorite(song)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        ArtistsView()
            .environmentObject(MusicLibrary.shared)
            .environmentObject(AudioPlayer.shared)
    }
}
