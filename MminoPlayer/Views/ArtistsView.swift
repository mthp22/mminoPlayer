//
//  ArtistsView.swift
//  MminoPlayer
//
//  Artists list and detail view

import SwiftUI

struct ArtistsView: View {
    let artists: [Artist]
    @ObservedObject var audioPlayer: AudioPlayer
    
    @State private var searchText = ""
    
    var filteredArtists: [Artist] {
        guard !searchText.isEmpty else { return artists }
        
        let lowercasedQuery = searchText.lowercased()
        return artists.filter { artist in
            artist.displayName.localizedCaseInsensitiveContains(lowercasedQuery)
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if filteredArtists.isEmpty {
                EmptyStateView(
                    icon: "person.2",
                    title: "No artists found",
                    message: "Try a different search term"
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120, maximum: 140), spacing: AppTheme.spacingMD)], spacing: AppTheme.spacingLG) {
                        ForEach(filteredArtists, id: \.id) { artist in
                            NavigationLink(destination: ArtistDetailView(artist: artist, audioPlayer: audioPlayer)) {
                                ArtistCard(artist: artist)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, AppTheme.spacingMD)
                }
            }
        }
        .navigationTitle("Artists")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search artists")
    }
}

struct ArtistCard: View {
    let artist: Artist
    
    var body: some View {
        VStack(spacing: AppTheme.spacingSM) {
            ZStack {
                Circle()
                    .fill(AppColors.surfaceElevated)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.grayMedium)
            }
            
            Text(artist.displayName)
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("\(artist.songCount) Songs")
                .font(AppTypography.caption)
                .foregroundColor(AppColors.grayLight)
        }
    }
}

struct ArtistDetailView: View {
    let artist: Artist
    @ObservedObject var audioPlayer: AudioPlayer
    @Environment(\.modelContext) private var modelContext
    @StateObject private var library = MusicLibrary.shared
    
    var artistSongs: [Song] {
        library.songs.filter { $0.displayArtist == artist.displayName }
    }
    
    var artistAlbums: [Album] {
        Album.fetchAlbums(from: artistSongs)
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    // Header
                    VStack(spacing: AppTheme.spacingMD) {
                        ZStack {
                            Circle()
                                .fill(AppColors.surfaceElevated)
                                .frame(width: 150, height: 150)
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.grayMedium)
                        }
                        
                        Text(artist.displayName)
                            .font(AppTypography.displayMedium)
                            .foregroundColor(AppColors.white)
                            .multilineTextAlignment(.center)
                        
                        Text("\(artist.songCount) Songs • \(artist.albumCount) Albums")
                            .font(AppTypography.headlineMedium)
                            .foregroundColor(AppColors.grayLight)
                    }
                    
                    // Albums section
                    if !artistAlbums.isEmpty {
                        VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                            Text("Albums")
                                .font(AppTypography.headlineMedium)
                                .foregroundColor(AppColors.white)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppTheme.spacingMD) {
                                    ForEach(artistAlbums, id: \.id) { album in
                                        AlbumGridItem(album: album)
                                    }
                                }
                            }
                        }
                        .padding(.top, AppTheme.spacingSM)
                    }
                    
                    // Songs section
                    VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                        Text("Songs")
                            .font(AppTypography.headlineMedium)
                            .foregroundColor(AppColors.white)
                        
                        VStack(spacing: AppTheme.spacingSM) {
                            ForEach(artistSongs, id: \.id) { song in
                                SongRow(
                                    song: song,
                                    isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                                    onTap: {
                                        audioPlayer.play(song, in: artistSongs)
                                    },
                                    onFavoriteToggle: {
                                        library.toggleFavorite(song)
                                    }
                                )
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.vertical, AppTheme.spacingLG)
            }
        }
        .navigationTitle(artist.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            library.configure(with: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        ArtistsView(artists: [], audioPlayer: AudioPlayer.shared)
    }
    .modelContainer(for: Song.self, inMemory: true)
}
