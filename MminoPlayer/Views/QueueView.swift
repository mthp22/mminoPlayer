//
//  QueueView.swift
//  MminoPlayer
//
//  Up Next queue view

import SwiftUI

struct QueueView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                if audioPlayer.queue.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet",
                        title: "Queue is empty",
                        message: "Songs you add will appear here"
                    )
                } else {
                    ScrollView {
                        VStack(spacing: AppTheme.spacingSM) {
                            // Now Playing section
                            if let currentSong = audioPlayer.currentSong {
                                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                                    Text("Now Playing")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.grayLight)
                                    
                                    SongRow(
                                        song: currentSong,
                                        isPlaying: true,
                                        onTap: {},
                                        onFavoriteToggle: {}
                                    )
                                }
                                .padding(.bottom, AppTheme.spacingLG)
                            }
                            
                            // Up Next section
                            if audioPlayer.queue.count > 1 {
                                VStack(alignment: .leading, spacing: AppTheme.spacingMD) {
                                    Text("Up Next")
                                        .font(AppTypography.caption)
                                        .foregroundColor(AppColors.grayLight)
                                    
                                    ForEach(audioPlayer.queue.indices.filter { $0 != audioPlayer.queueIndex }, id: \.self) { index in
                                        let song = audioPlayer.queue[index]
                                        
                                        HStack {
                                            SongRow(
                                                song: song,
                                                isPlaying: false,
                                                onTap: {
                                                    audioPlayer.play(song, in: audioPlayer.queue, at: index)
                                                },
                                                onFavoriteToggle: {
                                                    MusicLibrary.shared.toggleFavorite(song)
                                                }
                                            )
                                            
                                            Button(action: {
                                                audioPlayer.removeFromQueue(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(AppColors.grayMedium)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
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
            .navigationTitle("Queue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        audioPlayer.clearQueue()
                    }
                    .foregroundColor(AppColors.lime)
                    .disabled(audioPlayer.queue.count <= 1)
                }
            }
        }
    }
}

#Preview {
    QueueView(audioPlayer: AudioPlayer.shared)
}
