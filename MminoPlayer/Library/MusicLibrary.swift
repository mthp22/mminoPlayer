//
//  MusicLibrary.swift
//  MminoPlayer
//
//  SwiftData-based music library management

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class MusicLibrary: ObservableObject {
    static let shared = MusicLibrary()
    
    @Published var songs: [Song] = []
    @Published var playlists: [Playlist] = []
    @Published var isLoading = false
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
        loadSongs()
        loadPlaylists()
    }
    
    // MARK: - Songs
    
    func loadSongs() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
            songs = try context.fetch(descriptor)
        } catch {
            print("Error loading songs: \(error.localizedDescription)")
            songs = []
        }
    }
    
    func addSong(_ song: Song) {
        guard let context = modelContext else { return }
        
        context.insert(song)
        songs.insert(song, at: 0)
        
        saveContext()
    }
    
    func removeSong(_ song: Song) {
        guard let context = modelContext else { return }
        
        context.delete(song)
        
        if let index = songs.firstIndex(where: { $0.id == song.id }) {
            songs.remove(at: index)
        }
        
        saveContext()
    }
    
    func toggleFavorite(_ song: Song) {
        song.isFavorite.toggle()
        saveContext()
    }
    
    func getRecentlyPlayed(limit: Int = 10) -> [Song] {
        songs
            .filter { $0.lastPlayedDate != nil }
            .sorted { ($0.lastPlayedDate ?? .distantPast) > ($1.lastPlayedDate ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }
    
    func getRecentlyAdded(limit: Int = 10) -> [Song] {
        songs
            .sorted { $0.dateAdded > $1.dateAdded }
            .prefix(limit)
            .map { $0 }
    }
    
    func getFavorites() -> [Song] {
        songs.filter { $0.isFavorite }
    }
    
    func search(query: String) -> [Song] {
        guard !query.isEmpty else { return songs }
        
        let lowercasedQuery = query.lowercased()
        
        return songs.filter { song in
            song.displayTitle.localizedCaseInsensitiveContains(lowercasedQuery) ||
            song.displayArtist.localizedCaseInsensitiveContains(lowercasedQuery) ||
            (song.album?.localizedCaseInsensitiveContains(lowercasedQuery) ?? false) ||
            (song.genre?.localizedCaseInsensitiveContains(lowercasedQuery) ?? false)
        }
    }
    
    // MARK: - Playlists
    
    func loadPlaylists() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Playlist>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
            playlists = try context.fetch(descriptor)
            
            // Populate songs for each playlist
            for playlist in playlists {
                playlist.songs = songs.filter { playlist.songIDs.contains($0.id) }
            }
        } catch {
            print("Error loading playlists: \(error.localizedDescription)")
            playlists = []
        }
    }
    
    func createPlaylist(name: String) -> Playlist? {
        guard let context = modelContext else { return nil }
        
        let playlist = Playlist(name: name)
        context.insert(playlist)
        playlists.insert(playlist, at: 0)
        
        saveContext()
        return playlist
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        guard let context = modelContext else { return }
        
        context.delete(playlist)
        
        if let index = playlists.firstIndex(where: { $0.id == playlist.id }) {
            playlists.remove(at: index)
        }
        
        saveContext()
    }
    
    func renamePlaylist(_ playlist: Playlist, to name: String) {
        playlist.name = name
        playlist.dateModified = Date()
        saveContext()
    }
    
    func addSongToPlaylist(_ playlist: Playlist, song: Song) {
        playlist.addSong(song)
        playlist.songs = songs.filter { playlist.songIDs.contains($0.id) }
        saveContext()
    }
    
    func removeSongFromPlaylist(_ playlist: Playlist, song: Song) {
        playlist.removeSong(song)
        playlist.songs = songs.filter { playlist.songIDs.contains($0.id) }
        saveContext()
    }
    
    // MARK: - Context
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}
