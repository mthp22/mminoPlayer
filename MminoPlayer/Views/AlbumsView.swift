//
//  AlbumsView.swift
//  MminoPlayer
//
//  Albums grid and detail view

import SwiftUI

struct AlbumsView: View {
    let albums: [Album]
    @ObservedObject var audioPlayer: AudioPlayer
    
    @State private var searchText = ""
    
    var filteredAlbums: [Album] {
        guard !searchText.isEmpty else { return albums }
        
        let lowercasedQuery = searchText.lowercased()
        return albums.filter { album in
            album.displayTitle.localizedCaseInsensitiveContains(lowercasedQuery) ||
            album.displayArtist.localizedCaseInsensitiveContains(lowercasedQuery)
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if filteredAlbums.isEmpty {
                EmptyStateView(
                    icon: "record.circle",
                    title: "No albums found",
                    message: "Try a different search term"
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140, maximum: 160), spacing: AppTheme.spacingMD)], spacing: AppTheme.spacingLG) {
                        ForEach(filteredAlbums, id: \.id) { album in
                            NavigationLink(destination: AlbumDetailView(album: album, audioPlayer: audioPlayer)) {
                                AlbumCard(album: album)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, AppTheme.spacingMD)
                }
            }
        }
        .navigationTitle("Albums")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search albums")
    }
}

struct AlbumCard: View {
    let album: Album
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.spacingSM) {
            AlbumArtwork(
                artworkData: album.artworkData,
                size: 140,
                cornerRadius: AppTheme.cornerRadiusMD
            )
            
            Text(album.displayTitle)
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(album.displayArtist)
                .font(AppTypography.caption)
                .foregroundColor(AppColors.grayLight)
                .lineLimit(1)
        }
    }
}

struct AlbumDetailView: View {
    let album: Album
    @ObservedObject var audioPlayer: AudioPlayer
    @StateObject private var library = MusicLibrary.shared
    
    var sortedSongs: [Song] {
        library.songs.filter { album.songIDs.contains($0.id) }
            .sorted { ($0.trackNumber, $0.discNumber) < ($1.trackNumber, $1.discNumber) }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    // Header with artwork
                    VStack(spacing: AppTheme.spacingMD) {
                        AlbumArtwork(
                            artworkData: album.artworkData,
                            size: 240,
                            cornerRadius: AppTheme.cornerRadiusXL
                        )
                        
                        Text(album.displayTitle)
                            .font(AppTypography.displayMedium)
                            .foregroundColor(AppColors.white)
                            .multilineTextAlignment(.center)
                        
                        Text(album.displayArtist)
                            .font(AppTypography.headlineMedium)
                            .foregroundColor(AppColors.grayLight)
                        
                        // Play buttons
                        HStack(spacing: AppTheme.spacingLG) {
                            Button(action: playAll) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.lime)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppColors.background)
                                }
                            }
                            
                            Button(action: shufflePlay) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.glassBackground)
                                        .frame(width: 56, height: 56)
                                    
                                    Image(systemName: "shuffle")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppColors.white)
                                }
                            }
                        }
                        .padding(.top, AppTheme.spacingSM)
                    }
                    
                    // Track list
                    VStack(spacing: AppTheme.spacingSM) {
                        ForEach(sortedSongs, id: \.id) { song in
                            SongRow(
                                song: song,
                                isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                                showAlbum: false,
                                onTap: {
                                    audioPlayer.play(song, in: sortedSongs)
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
                .padding(.vertical, AppTheme.spacingLG)
            }
        }
        .navigationTitle(album.displayTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func playAll() {
        guard let firstSong = sortedSongs.first else { return }
        audioPlayer.play(firstSong, in: sortedSongs)
    }
    
    private func shufflePlay() {
        guard let firstSong = sortedSongs.first else { return }
        audioPlayer.shuffleEnabled = true
        audioPlayer.play(firstSong, in: sortedSongs)
    }
}

#Preview {
    NavigationStack {
        AlbumsView(albums: [], audioPlayer: AudioPlayer.shared)
    }
}
