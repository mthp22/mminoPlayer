//
//  FavoritesView.swift
//  MminoPlayer
//
//  Favorited songs view

import SwiftUI

struct FavoritesView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @StateObject private var library = MusicLibrary.shared
    
    var favoriteSongs: [Song] {
        library.getFavorites()
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if favoriteSongs.isEmpty {
                EmptyStateView(
                    icon: "heart",
                    title: "No favorites yet",
                    message: "Tap the heart icon on songs\nyou love to add them here."
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spacingSM) {
                        ForEach(favoriteSongs, id: \.id) { song in
                            SongRow(
                                song: song,
                                isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
                                onTap: {
                                    audioPlayer.play(song, in: favoriteSongs)
                                },
                                onFavoriteToggle: {
                                    library.toggleFavorite(song)
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
        .navigationTitle("Favorites")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
        }
    }
}

#Preview {
    NavigationStack {
        FavoritesView(audioPlayer: AudioPlayer.shared)
    }
}
