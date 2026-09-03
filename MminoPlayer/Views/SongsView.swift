//
//  SongsView.swift
//  MminoPlayer
//
//  List of all songs

import SwiftUI

struct SongsView: View {
    let songs: [Song]
    @ObservedObject var audioPlayer: AudioPlayer
    
    @State private var searchText = ""
    
    var filteredSongs: [Song] {
        guard !searchText.isEmpty else { return songs }
        
        let lowercasedQuery = searchText.lowercased()
        return songs.filter { song in
            song.displayTitle.localizedCaseInsensitiveContains(lowercasedQuery) ||
            song.displayArtist.localizedCaseInsensitiveContains(lowercasedQuery) ||
            (song.album?.localizedCaseInsensitiveContains(lowercasedQuery) ?? false)
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if filteredSongs.isEmpty {
                EmptyStateView(
                    icon: "music.note",
                    title: "No songs found",
                    message: "Try a different search term"
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spacingSM) {
                        ForEach(filteredSongs, id: \.id) { song in
                            SongRow(
                                song: song,
                                isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                                onTap: {
                                    audioPlayer.play(song, in: songs)
                                },
                                onFavoriteToggle: {
                                    MusicLibrary.shared.toggleFavorite(song)
                                }
                            )
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, AppTheme.spacingMD)
                }
            }
        }
        .navigationTitle("All Songs")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search songs")
    }
}

#Preview {
    NavigationStack {
        SongsView(songs: [], audioPlayer: AudioPlayer.shared)
    }
}
