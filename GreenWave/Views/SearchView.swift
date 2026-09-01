//
//  SearchView.swift
//  GreenWave
//
//  Search across library content
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    @State private var searchText = ""
    @State private var searchResults: (songs: [Song], albums: [Album], artists: [Artist], playlists: [Playlist])?
    
    var hasSearched: Bool {
        !searchText.isEmpty
    }
    
    var hasResults: Bool {
        guard let results = searchResults else { return false }
        return !results.songs.isEmpty || !results.albums.isEmpty || 
               !results.artists.isEmpty || !results.playlists.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppTheme.Spacing.xxl) {
                    if !hasSearched {
                        // Browse Sections
                        browseSections
                    } else if !hasResults {
                        // No Results
                        SearchEmptyState(query: searchText)
                    } else {
                        // Search Results
                        searchResultsView
                    }
                    
                    Spacer(minLength: 120)
                }
                .padding()
            }
            .navigationTitle("Search")
            .searchable(text: $searchText, prompt: "Songs, artists, albums")
            .onChange(of: searchText) { oldValue, newValue in
                performSearch(newValue)
            }
        }
    }
    
    // MARK: - Browse Sections
    
    private var browseSections: some View {
        Group {
            // Recent Searches placeholder
            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                Text("Browse Your Library")
                    .font(AppTypography.headlineMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150)), GridItem(.adaptive(minimum: 150))], spacing: AppTheme.Spacing.md) {
                    BrowseCard(title: "Songs", icon: "music.note", color: AppColors.green) {
                        // Navigate to songs
                    }
                    
                    BrowseCard(title: "Albums", icon: "square.stack.3d", color: AppColors.lime) {
                        // Navigate to albums
                    }
                    
                    BrowseCard(title: "Artists", icon: "person.2", color: AppColors.green) {
                        // Navigate to artists
                    }
                    
                    BrowseCard(title: "Playlists", icon: "list.bullet.rectangle", color: AppColors.lime) {
                        // Navigate to playlists
                    }
                }
            }
        }
    }
    
    // MARK: - Search Results
    
    private var searchResultsView: some View {
        Group {
            if let results = searchResults {
                // Songs
                if !results.songs.isEmpty {
                    searchSection(title: "Songs") {
                        ForEach(results.songs) { song in
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
                
                // Albums
                if !results.albums.isEmpty {
                    searchSection(title: "Albums") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.lg) {
                                ForEach(results.albums) { album in
                                    AlbumCard(album: album)
                                }
                            }
                        }
                    }
                }
                
                // Artists
                if !results.artists.isEmpty {
                    searchSection(title: "Artists") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.lg) {
                                ForEach(results.artists) { artist in
                                    ArtistCard(artist: artist)
                                }
                            }
                        }
                    }
                }
                
                // Playlists
                if !results.playlists.isEmpty {
                    searchSection(title: "Playlists") {
                        ForEach(results.playlists) { playlist in
                            PlaylistRow(playlist: playlist)
                            
                            Divider()
                                .background(AppColors.divider)
                        }
                    }
                }
            }
        }
    }
    
    private func searchSection<T: View>(title: String, @ViewBuilder content: () -> T) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            Text(title)
                .font(AppTypography.headlineMedium)
                .foregroundColor(AppColors.textPrimary)
            
            content()
        }
    }
    
    // MARK: - Actions
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else {
            searchResults = nil
            return
        }
        
        searchResults = musicLibrary.search(query: query.lowercased())
    }
    
    private func playSong(_ song: Song) {
        audioPlayer.play(song, inQueue: musicLibrary.songs.sorted())
    }
    
    private func toggleFavorite(_ song: Song) {
        musicLibrary.toggleFavorite(song)
    }
}

// MARK: - Supporting Views

struct BrowseCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Spacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                        .fill(color.opacity(0.2))
                        .frame(height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 32))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlaylistRow: View {
    let playlist: Playlist
    
    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                    .fill(AppColors.surface)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "music.note.list")
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryAction)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(playlist.songCount) Songs")
                    .font(AppTypography.captionSmall)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.vertical, AppTheme.Spacing.sm)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        SearchView()
            .environmentObject(MusicLibrary.shared)
            .environmentObject(AudioPlayer.shared)
    }
}
