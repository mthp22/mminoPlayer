//
//  SearchView.swift
//  MminoPlayer
//
//  Full-text search across library

import SwiftUI

struct SearchView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @StateObject private var library = MusicLibrary.shared
    
    @State private var searchText = ""
    @State private var selectedFilter: SearchFilter = .all
    
    enum SearchFilter: String, CaseIterable {
        case all = "All"
        case songs = "Songs"
        case albums = "Albums"
        case artists = "Artists"
        case playlists = "Playlists"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .songs: return "music.note"
            case .albums: return "record.circle"
            case .artists: return "person.2"
            case .playlists: return "list.bullet"
            }
        }
    }
    
    var searchResults: SearchResults {
        guard !searchText.isEmpty else {
            return SearchResults(songs: [], albums: [], artists: [], playlists: [])
        }
        
        let lowercasedQuery = searchText.lowercased()
        
        // Search songs
        let matchingSongs = library.songs.filter { song in
            song.displayTitle.localizedCaseInsensitiveContains(lowercasedQuery) ||
            song.displayArtist.localizedCaseInsensitiveContains(lowercasedQuery) ||
            (song.album?.localizedCaseInsensitiveContains(lowercasedQuery) ?? false)
        }
        
        // Search albums
        let allAlbums = Album.fetchAlbums(from: library.songs)
        let matchingAlbums = allAlbums.filter { album in
            album.displayTitle.localizedCaseInsensitiveContains(lowercasedQuery) ||
            album.displayArtist.localizedCaseInsensitiveContains(lowercasedQuery)
        }
        
        // Search artists
        let allArtists = Artist.fetchArtists(from: library.songs)
        let matchingArtists = allArtists.filter { artist in
            artist.displayName.localizedCaseInsensitiveContains(lowercasedQuery)
        }
        
        // Search playlists
        let matchingPlaylists = library.playlists.filter { playlist in
            playlist.name.localizedCaseInsensitiveContains(lowercasedQuery)
        }
        
        return SearchResults(
            songs: matchingSongs,
            albums: matchingAlbums,
            artists: matchingArtists,
            playlists: matchingPlaylists
        )
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if searchText.isEmpty {
                // Show browsing sections when not searching
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        Text("Browse")
                            .font(AppTypography.displayMedium)
                            .foregroundColor(AppColors.white)
                            .padding(.top, AppTheme.spacingMD)
                        
                        // Filter buttons
                        filterButtons
                        
                        // Quick access sections
                        VStack(spacing: AppTheme.spacingSM) {
                            ForEach(library.getRecentlyPlayed().prefix(5), id: \.id) { song in
                                SongRow(
                                    song: song,
                                    isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                                    onTap: {
                                        audioPlayer.play(song, in: library.songs)
                                    },
                                    onFavoriteToggle: {
                                        library.toggleFavorite(song)
                                    }
                                )
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                }
            } else if searchResults.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No results found",
                    message: "Try a different search term"
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        // Filter buttons
                        filterButtons
                        
                        // Results
                        if selectedFilter == .all || selectedFilter == .songs {
                            resultsSection(title: "Songs", count: searchResults.songs.count) {
                                ForEach(searchResults.songs.prefix(10), id: \.id) { song in
                                    SongRow(
                                        song: song,
                                        isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                                        onTap: {
                                            audioPlayer.play(song, in: searchResults.songs)
                                        },
                                        onFavoriteToggle: {
                                            library.toggleFavorite(song)
                                        }
                                    )
                                }
                            }
                        }
                        
                        if selectedFilter == .all || selectedFilter == .albums {
                            resultsSection(title: "Albums (\(searchResults.albums.count))", count: searchResults.albums.count) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.spacingMD) {
                                        ForEach(searchResults.albums.prefix(6), id: \.id) { album in
                                            NavigationLink(destination: AlbumDetailView(album: album, audioPlayer: audioPlayer)) {
                                                AlbumGridItem(album: album)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                        
                        if selectedFilter == .all || selectedFilter == .artists {
                            resultsSection(title: "Artists (\(searchResults.artists.count))", count: searchResults.artists.count) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.spacingMD) {
                                        ForEach(searchResults.artists.prefix(6), id: \.id) { artist in
                                            NavigationLink(destination: ArtistDetailView(artist: artist, audioPlayer: audioPlayer)) {
                                                ArtistGridItem(artist: artist)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                        
                        if selectedFilter == .all || selectedFilter == .playlists {
                            resultsSection(title: "Playlists (\(searchResults.playlists.count))", count: searchResults.playlists.count) {
                                ForEach(searchResults.playlists, id: \.id) { playlist in
                                    NavigationLink(destination: PlaylistDetailView(playlist: playlist, audioPlayer: audioPlayer)) {
                                        PlaylistRow(playlist: playlist)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, AppTheme.spacingMD)
                }
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search songs, artists, albums, playlists")
        .onAppear {
        }
    }
    
    private var filterButtons: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingSM) {
                ForEach(SearchFilter.allCases, id: \.self) { filter in
                    Button(action: { selectedFilter = filter }) {
                        HStack(spacing: AppTheme.spacingXXS) {
                            Image(systemName: filter.icon)
                                .font(.system(size: 14))
                            Text(filter.rawValue)
                                .font(AppTypography.caption)
                        }
                        .padding(.horizontal, AppTheme.spacingMD)
                        .padding(.vertical, AppTheme.spacingSM)
                        .background(selectedFilter == filter ? AppColors.lime : AppColors.surfaceElevated)
                        .foregroundColor(selectedFilter == filter ? AppColors.background : AppColors.grayLight)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    @ViewBuilder
    private func resultsSection(title: String, count: Int, @ViewBuilder content: () -> some View) -> some View {
        if count > 0 {
            VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                Text(title)
                    .font(AppTypography.headlineMedium)
                    .foregroundColor(AppColors.white)
                
                content()
            }
        }
    }
}

struct SearchResults {
    let songs: [Song]
    let albums: [Album]
    let artists: [Artist]
    let playlists: [Playlist]
    
    var isEmpty: Bool {
        songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty
    }
}

#Preview {
    NavigationStack {
        SearchView(audioPlayer: AudioPlayer.shared)
    }
}
