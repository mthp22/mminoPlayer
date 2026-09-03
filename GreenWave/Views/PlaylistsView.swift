//
//  PlaylistsView.swift
//  GreenWave
//
//  User playlists management
//

import SwiftUI
import SwiftData

struct PlaylistsView: View {
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    @State private var showingCreatePlaylist = false
    @State private var newPlaylistName = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if musicLibrary.playlists.isEmpty {
                    PlaylistsEmptyState(onCreatePlaylist: {
                        showingCreatePlaylist = true
                    })
                } else {
                    List {
                        ForEach(musicLibrary.playlists) { playlist in
                            NavigationLink(destination: PlaylistDetailView(playlist: playlist)) {
                                HStack(spacing: AppTheme.Spacing.md) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg)
                                            .fill(AppColors.surface)
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "music.note.list")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.primaryAction)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(playlist.name)
                                            .font(AppTypography.bodyMedium)
                                            .foregroundColor(AppColors.textPrimary)
                                        
                                        Text("\(playlist.songCount) Songs")
                                            .font(AppTypography.captionSmall)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.textTertiary)
                                }
                                .padding(.vertical, AppTheme.Spacing.sm)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Playlists")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingCreatePlaylist = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryAction)
                    }
                }
            }
            .sheet(isPresented: $showingCreatePlaylist) {
                CreatePlaylistSheet(
                    playlistName: $newPlaylistName,
                    onCreate: createPlaylist
                )
            }
        }
    }
    
    private func createPlaylist() {
        guard !newPlaylistName.isEmpty else { return }
        _ = musicLibrary.createPlaylist(name: newPlaylistName)
        newPlaylistName = ""
        showingCreatePlaylist = false
    }
}

// MARK: - Create Playlist Sheet

struct CreatePlaylistSheet: View {
    @Binding var playlistName: String
    var onCreate: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.lg) {
                    TextField("Playlist Name", text: $playlistName)
                        .font(AppTypography.bodyLarge)
                        .foregroundColor(AppColors.textPrimary)
                        .padding()
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.lg))
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        onCreate()
                    }
                    .foregroundColor(playlistName.isEmpty ? AppColors.textTertiary : AppColors.primaryAction)
                    .disabled(playlistName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Playlist Detail View

struct PlaylistDetailView: View {
    let playlist: Playlist
    @EnvironmentObject var musicLibrary: MusicLibrary
    @EnvironmentObject var audioPlayer: AudioPlayer
    @Environment(\.dismiss) var dismiss
    
    var songs: [Song] {
        musicLibrary.songs.filter { playlist.songIds.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                // Header
                HStack(spacing: AppTheme.Spacing.lg) {
                    ZStack {
                        RoundedRectangle(cornerRadius: AppTheme.CornerRadius.xl)
                            .fill(AppColors.surface)
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "music.note.list")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.primaryAction)
                    }
                    
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                        Text(playlist.name)
                            .font(AppTypography.headlineLarge)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("\(songs.count) Songs")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // Play Buttons
                HStack(spacing: AppTheme.Spacing.lg) {
                    Button(action: { playPlaylist() }) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.background)
                            .frame(width: 56, height: 56)
                            .background(AppColors.primaryAction)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { shufflePlaylist() }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primaryAction)
                            .frame(width: 56, height: 56)
                            .background(AppColors.primaryAction.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                
                // Track List
                VStack(spacing: 0) {
                    ForEach(Array(songs.enumerated()), id: \.element.id) { index, song in
                        CompactSongRow(
                            song: song,
                            index: index,
                            onTap: { playTrack(at: index) }
                        )
                        
                        Divider()
                            .background(AppColors.divider)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { deletePlaylist() }) {
                    Image(systemName: "trash")
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
    }
    
    private func playPlaylist() {
        guard let firstSong = songs.first else { return }
        audioPlayer.play(firstSong, inQueue: songs)
    }
    
    private func shufflePlaylist() {
        let shuffled = songs.shuffled()
        guard let firstSong = shuffled.first else { return }
        audioPlayer.play(firstSong, inQueue: shuffled)
    }
    
    private func playTrack(at index: Int) {
        let remainingTracks = Array(songs.dropFirst(index + 1))
        audioPlayer.play(songs[index], inQueue: remainingTracks)
    }
    
    private func deletePlaylist() {
        musicLibrary.deletePlaylist(playlist)
        dismiss()
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        PlaylistsView()
            .environmentObject(MusicLibrary.shared)
            .environmentObject(AudioPlayer.shared)
    }
}
