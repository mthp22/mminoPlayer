//
//  SongsView.swift
//  GreenWave
//
//  List of all songs in the library
//

import SwiftUI

struct SongsView: View {
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    
    var body: some View {
        NavigationStack {
            Group {
                if musicLibrary.songs.isEmpty {
                    LibraryEmptyState(onImportMusic: {})
                } else {
                    List {
                        ForEach(musicLibrary.songs.sorted()) { song in
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
            .navigationTitle("Songs")
        }
    }
    
    private func playSong(_ song: Song) {
        audioPlayer.play(song, inQueue: musicLibrary.songs.sorted())
    }
    
    private func toggleFavorite(_ song: Song) {
        musicLibrary.toggleFavorite(song)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        SongsView()
            .environmentObject(MusicLibrary.shared)
            .environmentObject(AudioPlayer.shared)
    }
}
