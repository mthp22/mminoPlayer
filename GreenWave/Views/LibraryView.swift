//
//  LibraryView.swift
//  GreenWave
//
//  Main library screen showing all music collections
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    @Binding var showingImportSheet: Bool
    
    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: AppTheme.Spacing.lg)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xxl) {
                        // Header
                        headerSection
                        
                        if musicLibrary.songs.isEmpty {
                            // Empty State
                            LibraryEmptyState(onImportMusic: {
                                showingImportSheet = true
                            })
                            .padding(.top, AppTheme.Spacing.xxl * 2)
                        } else {
                            // Recently Played
                            if !musicLibrary.recentlyPlayed.isEmpty {
                                sectionHeader(title: "Recently Played", actionTitle: "See All")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.Spacing.md) {
                                        ForEach(musicLibrary.recentlyPlayed.prefix(10)) { song in
                                            SongCard(song: song)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Recently Added
                            if !musicLibrary.recentlyAdded.isEmpty {
                                sectionHeader(title: "Recently Added", actionTitle: "See All")
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.Spacing.md) {
                                        ForEach(musicLibrary.recentlyAdded.prefix(10)) { song in
                                            SongCard(song: song)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Songs Section
                            songsSection
                            
                            // Albums Section
                            albumsSection
                            
                            // Artists Section
                            artistsSection
                            
                            Spacer(minLength: 120)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingImportSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.primaryAction)
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            Text(greeting)
                .font(AppTypography.headlineLarge)
                .foregroundColor(AppColors.textPrimary)
            
            Text("\(musicLibrary.songs.count) Songs • \(musicLibrary.albums.count) Albums")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private func sectionHeader(title: String, actionTitle: String = "") -> some View {
        HStack {
            Text(title)
                .font(AppTypography.headlineMedium)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            if !actionTitle.isEmpty {
                Text(actionTitle)
                    .font(AppTypography.buttonSmall)
                    .foregroundColor(AppColors.primaryAction)
            }
        }
        .padding(.horizontal)
    }
    
    private var songsSection: some View {
        Group {
            sectionHeader(title: "Songs")
            
            VStack(spacing: 0) {
                ForEach(musicLibrary.songs.sorted().prefix(20)) { song in
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
            .padding(.horizontal)
        }
    }
    
    private var albumsSection: some View {
        Group {
            sectionHeader(title: "Albums")
            
            LazyVGrid(columns: columns, spacing: AppTheme.Spacing.lg) {
                ForEach(musicLibrary.albums.prefix(6)) { album in
                    NavigationLink(destination: AlbumDetailView(album: album)) {
                        AlbumCard(album: album)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var artistsSection: some View {
        Group {
            sectionHeader(title: "Artists")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.lg) {
                    ForEach(musicLibrary.artists.prefix(10)) { artist in
                        ArtistCard(artist: artist)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Actions
    
    private func playSong(_ song: Song) {
        audioPlayer.play(song, inQueue: musicLibrary.songs.sorted())
    }
    
    private func toggleFavorite(_ song: Song) {
        musicLibrary.toggleFavorite(song)
    }
    
    // MARK: - Computed Properties
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 {
            return "Good morning"
        } else if hour < 17 {
            return "Good afternoon"
        } else {
            return "Good evening"
        }
    }
}

// MARK: - Supporting Views

struct SongCard: View {
    let song: Song
    @ObservedObject var audioPlayer = AudioPlayer.shared
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            AlbumArtwork(song: song, size: 140, cornerRadius: AppTheme.CornerRadius.lg)
            
            Text(song.displayTitle)
                .font(AppTypography.titleSmall)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            
            Text(song.displayArtist)
                .font(AppTypography.captionSmall)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 140)
    }
}

struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            GridAlbumArtwork(album: album, size: 150)
            
            Text(album.title)
                .font(AppTypography.titleSmall)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
            
            Text(album.displayArtist)
                .font(AppTypography.captionSmall)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
        }
    }
}

struct ArtistCard: View {
    let artist: Artist
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(AppColors.surface)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(artist.name)
                .font(AppTypography.titleSmall)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
        }
        .frame(width: 100)
    }
}

#Preview {
    LibraryView(showingImportSheet: .constant(false))
        .environmentObject(MusicLibrary.shared)
        .environmentObject(AudioPlayer.shared)
}
