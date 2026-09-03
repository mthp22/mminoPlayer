//
//  FavoritesView.swift
//  GreenWave
//
//  View for favorited songs
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        NavigationStack {
            Group {
                if musicLibrary.favorites.isEmpty {
                    FavoritesEmptyState()
                } else {
                    List {
                        ForEach(musicLibrary.favorites.sorted()) { song in
                            SongRow(
                                song: song,
                                showAlbum: true,
                                onTap: { playSong(song) },
                                onFavoriteToggle: { toggleFavorite(song) },
                                onMore: {}
                            )
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
        }
    }
    
    private func playSong(_ song: Song) {
        audioPlayer.play(song, inQueue: musicLibrary.favorites.sorted())
    }
    
    private func toggleFavorite(_ song: Song) {
        musicLibrary.toggleFavorite(song)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        FavoritesView()
            .environmentObject(MusicLibrary.shared)
            .environmentObject(AudioPlayer.shared)
    }
}
