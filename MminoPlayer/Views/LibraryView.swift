//
//  LibraryView.swift
//  MminoPlayer
//
//  Home screen with library sections

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var audioPlayer: AudioPlayer
    @StateObject private var library = MusicLibrary.shared
    
    @State private var searchText = ""
    @State private var showingImporter = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                        // Header
                        headerView
                        
                        // Quick actions
                        quickActionsView
                        
                        // Sections
                        if library.songs.isEmpty {
                            EmptyStateView(
                                icon: "music.note",
                                title: "Your library is empty",
                                message: "Import music from Files\nto start building your\noffline library.",
                                actionTitle: "Add Music",
                                action: { showingImporter = true }
                            )
                            .padding(.top, AppTheme.spacingXXL * 2)
                        } else {
                            // Recently Played
                            if !library.getRecentlyPlayed().isEmpty {
                                sectionView(title: "Recently Played", songs: library.getRecentlyPlayed())
                            }
                            
                            // Recently Added
                            if !library.getRecentlyAdded().isEmpty {
                                sectionView(title: "Recently Added", songs: library.getRecentlyAdded())
                            }
                            
                            // All Songs
                            sectionView(title: "All Songs", songs: library.songs)
                            
                            // Albums
                            albumsSection
                            
                            // Artists
                            artistsSection
                            
                            // Favorites
                            if !library.getFavorites().isEmpty {
                                sectionView(title: "Favorites", songs: library.getFavorites())
                            }
                        }
                        
                        // Bottom padding for mini player
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.top, AppTheme.spacingSM)
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingImporter = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.lime)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search songs, artists, albums")
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: FileImporter.shared.supportedTypes,
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result: result)
            }
        }
        .onAppear {
            library.configure(with: modelContext)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
            Text(greeting)
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.grayLight)
            
            Text("Your Music")
                .font(AppTypography.displayLarge)
                .foregroundColor(AppColors.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, AppTheme.spacingSM)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppTheme.spacingMD) {
                QuickActionCard(
                    icon: "folder.badge.plus",
                    title: "Import",
                    color: AppColors.lime
                ) {
                    showingImporter = true
                }
                
                NavigationLink(destination: FavoritesView(audioPlayer: audioPlayer)) {
                    QuickActionCard(
                        icon: "heart.fill",
                        title: "Favorites",
                        color: AppColors.green
                    )
                }
                
                NavigationLink(destination: PlaylistsView(audioPlayer: audioPlayer)) {
                    QuickActionCard(
                        icon: "list.bullet",
                        title: "Playlists",
                        color: AppColors.greenLight
                    )
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private func sectionView(title: String, songs: [Song]) -> some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text(title)
                    .font(AppTypography.headlineMedium)
                    .foregroundColor(AppColors.white)
                
                Spacer()
                
                if title == "All Songs" {
                    NavigationLink("See All") {
                        SongsView(songs: library.songs, audioPlayer: audioPlayer)
                    }
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.lime)
                }
            }
            
            VStack(spacing: AppTheme.spacingSM) {
                ForEach(Array(songs.prefix(5)), id: \.id) { song in
                    SongRow(
                        song: song,
                        isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                        onTap: {
                            audioPlayer.play(song, in: songs)
                        },
                        onFavoriteToggle: {
                            library.toggleFavorite(song)
                        }
                    )
                }
            }
        }
        .padding(.top, AppTheme.spacingMD)
    }
    
    private var albumsSection: some View {
        let albums = Album.fetchAlbums(from: library.songs)
        
        return VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text("Albums")
                    .font(AppTypography.headlineMedium)
                    .foregroundColor(AppColors.white)
                
                Spacer()
                
                NavigationLink("See All") {
                    AlbumsView(albums: albums, audioPlayer: audioPlayer)
                }
                .font(AppTypography.caption)
                .foregroundColor(AppColors.lime)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacingMD) {
                    ForEach(albums.prefix(6), id: \.id) { album in
                        NavigationLink(destination: AlbumDetailView(album: album, audioPlayer: audioPlayer)) {
                            AlbumGridItem(album: album)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.top, AppTheme.spacingMD)
    }
    
    private var artistsSection: some View {
        let artists = Artist.fetchArtists(from: library.songs)
        
        return VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
            HStack {
                Text("Artists")
                    .font(AppTypography.headlineMedium)
                    .foregroundColor(AppColors.white)
                
                Spacer()
                
                NavigationLink("See All") {
                    ArtistsView(artists: artists, audioPlayer: audioPlayer)
                }
                .font(AppTypography.caption)
                .foregroundColor(AppColors.lime)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.spacingMD) {
                    ForEach(artists.prefix(6), id: \.id) { artist in
                        NavigationLink(destination: ArtistDetailView(artist: artist, audioPlayer: audioPlayer)) {
                            ArtistGridItem(artist: artist)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.top, AppTheme.spacingMD)
    }
    
    // MARK: - File Import
    
    private func handleFileImport(result: Result<[URL], Error>) {
        Task {
            let musicDir = FileImporter.shared.ensureMusicDirectory()
            
            switch result {
            case .success(let urls):
                for url in urls {
                    do {
                        if let song = try await FileImporter.shared.importFile(from: url, to: musicDir) {
                            library.addSong(song)
                        }
                    } catch {
                        print("Error importing file: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                print("File import error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Quick Action Card

struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.spacingSM) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundColor(AppColors.grayLight)
            }
            .frame(width: 80)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Album Grid Item

struct AlbumGridItem: View {
    let album: Album
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSM) {
            AlbumArtwork(
                artworkData: album.artworkData,
                size: 120,
                cornerRadius: AppTheme.cornerRadiusMD
            )
            
            Text(album.displayTitle)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.white)
                .lineLimit(1)
            
            Text(album.displayArtist)
                .font(AppTypography.captionSmall)
                .foregroundColor(AppColors.grayLight)
                .lineLimit(1)
        }
        .frame(width: 120)
    }
}

// MARK: - Artist Grid Item

struct ArtistGridItem: View {
    let artist: Artist
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSM) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceElevated)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundColor(AppColors.grayMedium)
            }
            
            Text(artist.displayName)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.white)
                .lineLimit(1)
            
            Text("\(artist.songCount) Songs")
                .font(AppTypography.captionSmall)
                .foregroundColor(AppColors.grayLight)
                .lineLimit(1)
        }
        .frame(width: 100)
    }
}

#Preview {
    LibraryView(audioPlayer: AudioPlayer.shared)
        .modelContainer(for: Song.self, inMemory: true)
}
