//
//  PlaylistsView.swift
//  MminoPlayer
//
//  Playlists management view

import SwiftUI
import SwiftData

struct PlaylistsView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @StateObject private var library = MusicLibrary.shared
    
    @State private var showingCreatePlaylist = false
    @State private var newPlaylistName = ""
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            if library.playlists.isEmpty {
                EmptyStateView(
                    icon: "list.bullet",
                    title: "No playlists yet",
                    message: "Create your first playlist\nto organize your music.",
                    actionTitle: "Create Playlist",
                    action: { showingCreatePlaylist = true }
                )
            } else {
                ScrollView {
                    VStack(spacing: AppTheme.spacingMD) {
                        ForEach(library.playlists, id: \.id) { playlist in
                            NavigationLink(destination: PlaylistDetailView(playlist: playlist, audioPlayer: audioPlayer)) {
                                PlaylistRow(playlist: playlist)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, AppTheme.spacingMD)
                    .padding(.vertical, AppTheme.spacingMD)
                }
            }
        }
        .navigationTitle("Playlists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreatePlaylist = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.lime)
                }
            }
        }
        .sheet(isPresented: $showingCreatePlaylist) {
            CreatePlaylistSheet(
                playlistName: $newPlaylistName,
                onCreate: createPlaylist,
                onCancel: { newPlaylistName = "" }
            )
        }
        .onAppear {
        }
    }
    
    private func createPlaylist() {
        guard !newPlaylistName.isEmpty else { return }
        
        if let playlist = library.createPlaylist(name: newPlaylistName) {
            library.addSongToPlaylist(playlist, song: Song(title: "Example", fileURL: ""))
        }
        newPlaylistName = ""
    }
}

struct PlaylistRow: View {
    let playlist: Playlist
    
    var body: some View {
        GlassCard(padding: AppTheme.spacingMD, cornerRadius: AppTheme.cornerRadiusLG) {
            HStack(spacing: AppTheme.spacingMD) {
                // Playlist artwork placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                        .fill(AppColors.surfaceElevated)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "music.note.list")
                        .font(.system(size: 24))
                        .foregroundColor(AppColors.grayMedium)
                }
                
                VStack(alignment: .leading, spacing: AppTheme.spacingXXS) {
                    Text(playlist.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.white)
                        .lineLimit(1)
                    
                    Text("\(playlist.songCount) Songs")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.grayLight)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.grayMedium)
            }
        }
    }
}

struct PlaylistDetailView: View {
    let playlist: Playlist
    @ObservedObject var audioPlayer: AudioPlayer
    @StateObject private var library = MusicLibrary.shared
    
    var sortedSongs: [Song] {
        library.songs.filter { playlist.songIDs.contains($0.id) }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: AppTheme.spacingLG) {
                    // Header
                    VStack(spacing: AppTheme.spacingMD) {
                        ZStack {
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusXL)
                                .fill(AppColors.surfaceElevated)
                                .frame(width: 180, height: 180)
                            
                            Image(systemName: "music.note.list")
                                .font(.system(size: 60))
                                .foregroundColor(AppColors.grayMedium)
                        }
                        
                        Text(playlist.name)
                            .font(AppTypography.displayMedium)
                            .foregroundColor(AppColors.white)
                            .multilineTextAlignment(.center)
                        
                        Text("\(playlist.songCount) Songs • \(playlist.formattedDuration)")
                            .font(AppTypography.headlineMedium)
                            .foregroundColor(AppColors.grayLight)
                        
                        // Play button
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
                        .padding(.top, AppTheme.spacingSM)
                    }
                    
                    // Songs list
                    VStack(spacing: AppTheme.spacingSM) {
                        ForEach(sortedSongs, id: \.id) { song in
                            SongRow(
                                song: song,
                                isPlaying: audioPlayer.currentSong?.id == song.id && audioPlayer.isPlaying,
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
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
        }
    }
    
    private func playAll() {
        guard let firstSong = sortedSongs.first else { return }
        audioPlayer.play(firstSong, in: sortedSongs)
    }
}

struct CreatePlaylistSheet: View {
    @Binding var playlistName: String
    let onCreate: () -> Void
    let onCancel: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: AppTheme.spacingLG) {
                    TextField("Playlist Name", text: $playlistName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(AppColors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD))
                }
                .padding()
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                        dismiss()
                    }
                    .foregroundColor(AppColors.grayLight)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        onCreate()
                        dismiss()
                    }
                    .foregroundColor(AppColors.lime)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlaylistsView(audioPlayer: AudioPlayer.shared)
    }
}
