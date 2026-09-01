//
//  QueueView.swift
//  GreenWave
//
//  Queue view for managing upcoming tracks
//

import SwiftUI

struct QueueView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    @EnvironmentObject var musicLibrary: MusicLibrary
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            Group {
                if audioPlayer.queue.isEmpty {
                    EmptyStateView(
                        icon: "list.bullet",
                        title: "Queue is empty",
                        message: "Add songs to the queue to play them next."
                    )
                } else {
                    List {
                        ForEach(Array(audioPlayer.queue.enumerated()), id: \.element.id) { index, song in
                            HStack(spacing: AppTheme.Spacing.md) {
                                Text("\(index + 1)")
                                    .font(AppTypography.captionSmall)
                                    .foregroundColor(AppColors.textTertiary)
                                    .frame(width: 24)
                                
                                AlbumArtwork(song: song, size: 44, cornerRadius: AppTheme.CornerRadius.md, showShadow: false)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(song.displayTitle)
                                        .font(AppTypography.bodyMedium)
                                        .foregroundColor(AppColors.textPrimary)
                                        .lineLimit(1)
                                    
                                    Text(song.displayArtist)
                                        .font(AppTypography.captionSmall)
                                        .foregroundColor(AppColors.textSecondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    audioPlayer.removeFromQueue(at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, AppTheme.Spacing.sm)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Up Next")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") {
                    audioPlayer.clearQueue()
                }
                .foregroundColor(AppColors.primaryAction)
            }
        }
    }
}

#Preview {
    NavigationView {
        QueueView()
            .environmentObject(AudioPlayer.shared)
            .environmentObject(MusicLibrary.shared)
    }
}
