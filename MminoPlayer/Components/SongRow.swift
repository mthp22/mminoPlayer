//
//  SongRow.swift
//  MminoPlayer
//
//  Song list row component with artwork, metadata, favorite toggle, and a
//  context menu for queue/playlist actions.

import SwiftUI

struct SongRow: View {
    let song: Song
    let isPlaying: Bool
    let showAlbum: Bool
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    
    init(
        song: Song,
        isPlaying: Bool = false,
        showAlbum: Bool = true,
        onTap: @escaping () -> Void,
        onFavoriteToggle: @escaping () -> Void
    ) {
        self.song = song
        self.isPlaying = isPlaying
        self.showAlbum = showAlbum
        self.onTap = onTap
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        GlassCard(
            padding: AppTheme.spacingSM,
            cornerRadius: AppTheme.cornerRadiusMD
        ) {
            HStack(spacing: AppTheme.spacingMD) {
                // Artwork
                AlbumArtwork(
                    artworkData: song.artworkData,
                    artworkID: song.id.uuidString,
                    size: AppTheme.artworkSizeSmall,
                    cornerRadius: AppTheme.cornerRadiusSM
                )
                
                // Info
                VStack(alignment: .leading, spacing: AppTheme.spacingXXS) {
                    Text(song.displayTitle)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(isPlaying ? AppColors.lime : AppColors.white)
                        .lineLimit(1)

                    Text(secondLine)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.grayLight)
                        .lineLimit(1)
                }

                Spacer(minLength: AppTheme.spacingXS)

                // Duration and controls
                HStack(spacing: AppTheme.spacingMD) {
                    Text(song.formattedDuration)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.grayMedium)
                        .monospacedDigit()
                        .accessibilityLabel("Duration, \(song.formattedDuration)")

                    Button(action: onFavoriteToggle) {
                        Image(systemName: song.isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(song.isFavorite ? AppColors.lime : AppColors.grayMedium)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(song.isFavorite ? "Remove from favorites" : "Add to favorites")

                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.grayMedium)
                        .accessibilityHidden(true)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(song.displayTitle), \(secondLine), \(song.formattedDuration)")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Plays the song")
        .accessibilityAction { onTap() }
        .accessibilityAction(named: Text("Favorite")) { onFavoriteToggle() }
        .contextMenu {
            Button {
                AudioPlayer.shared.playNext(song)
            } label: {
                Label("Play Next", systemImage: "text.insert")
            }

            Button {
                AudioPlayer.shared.addAfterNext(song)
            } label: {
                Label("Play After Next", systemImage: "text.line.first.and.arrowtriangle.forward")
            }

            Button {
                AudioPlayer.shared.addToQueue(song)
            } label: {
                Label("Add to Queue (last)", systemImage: "text.badge.plus")
            }

            Menu {
                if MusicLibrary.shared.playlists.isEmpty {
                    Text("No playlists yet")
                } else {
                    ForEach(MusicLibrary.shared.playlists, id: \.id) { playlist in
                        Button(playlist.name) {
                            MusicLibrary.shared.addSongToPlaylist(playlist, song: song)
                        }
                    }
                }
            } label: {
                Label("Add to Playlist", systemImage: "music.note.list")
            }

            Button(action: onFavoriteToggle) {
                Label(
                    song.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: song.isFavorite ? "heart.slash" : "heart"
                )
            }
        }
    }

    private var secondLine: String {
        showAlbum ? "\(song.displayArtist) • \(song.displayAlbum)" : song.displayArtist
    }
}

#Preview {
    VStack(spacing: AppTheme.spacingSM) {
        SongRow(
            song: Song(
                title: "Example Song",
                artist: "Artist Name",
                album: "Album Title",
                duration: 234.5,
                fileURL: "file://example.mp3"
            ),
            isPlaying: false,
            onTap: {},
            onFavoriteToggle: {}
        )
        
        SongRow(
            song: Song(
                title: "Another Song",
                artist: "Another Artist",
                album: "Another Album",
                duration: 189.0,
                fileURL: "file://example2.mp3",
                isFavorite: true
            ),
            isPlaying: true,
            onTap: {},
            onFavoriteToggle: {}
        )
    }
    .padding()
    .background(AppColors.background)
}
