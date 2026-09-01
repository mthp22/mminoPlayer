//
//  MusicLibrary.swift
//  GreenWave
//
//  Manages the local music library using SwiftData
//

import Foundation
import SwiftData
import Combine

@MainActor
final class MusicLibrary: ObservableObject {
    static let shared = MusicLibrary()
    
    @Published var songs: [Song] = []
    @Published var albums: [Album] = []
    @Published var artists: [Artist] = []
    @Published var playlists: [Playlist] = []
    @Published var favorites: [Song] = []
    @Published var recentlyPlayed: [Song] = []
    @Published var recentlyAdded: [Song] = []
    @Published var isLoading = false
    
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupModelContainer()
    }
    
    // MARK: - Public Methods
    
    func setupModelContainer() {
        do {
            let schema = Schema([
                Song.self,
                Playlist.self
            ])
            let configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            let container = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = ModelContext(container)
            
            loadLibrary()
        } catch {
            print("Failed to create ModelContainer: \(error)")
        }
    }
    
    func loadLibrary() {
        guard let context = modelContext else { return }
        
        isLoading = true
        
        Task.detached {
            do {
                let songDescriptor = FetchDescriptor<Song>(sortBy: [SortDescriptor(\.title)])
                let allSongs = try context.fetch(songDescriptor)
                
                let playlistDescriptor = FetchDescriptor<Playlist>(sortBy: [SortDescriptor(\.name)])
                let allPlaylists = try context.fetch(playlistDescriptor)
                
                await MainActor.run {
                    self.songs = allSongs
                    self.playlists = allPlaylists
                    self.updateDerivedCollections()
                    self.isLoading = false
                }
            } catch {
                print("Failed to fetch songs: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func addSong(_ song: Song) {
        guard let context = modelContext else { return }
        
        // Check for duplicates
        if songs.contains(where: { $0.id == song.id }) {
            return
        }
        
        context.insert(song)
        songs.append(song)
        updateDerivedCollections()
        
        saveContext()
    }
    
    func removeSong(_ song: Song) {
        guard let context = modelContext else { return }
        
        context.delete(song)
        songs.removeAll { $0.id == song.id }
        updateDerivedCollections()
        
        saveContext()
    }
    
    func toggleFavorite(_ song: Song) {
        song.isFavorite.toggle()
        updateDerivedCollections()
        saveContext()
    }
    
    func updatePlayCount(for song: Song) {
        song.playCount += 1
        song.lastPlayedDate = Date()
        updateDerivedCollections()
        saveContext()
    }
    
    // MARK: - Playlist Management
    
    func createPlaylist(name: String) -> Playlist? {
        guard let context = modelContext else { return nil }
        
        let playlist = Playlist(name: name)
        context.insert(playlist)
        playlists.append(playlist)
        saveContext()
        
        return playlist
    }
    
    func deletePlaylist(_ playlist: Playlist) {
        guard let context = modelContext else { return }
        
        context.delete(playlist)
        playlists.removeAll { $0.id == playlist.id }
        saveContext()
    }
    
    func addToPlaylist(_ playlist: Playlist, songId: UUID) {
        guard !playlist.songIds.contains(songId) else { return }
        
        playlist.songIds.append(songId)
        playlist.dateModified = Date()
        saveContext()
    }
    
    func removeFromPlaylist(_ playlist: Playlist, songId: UUID) {
        playlist.songIds.removeAll { $0 == songId }
        playlist.dateModified = Date()
        saveContext()
    }
    
    func reorderPlaylist(_ playlist: Playlist, from source: IndexSet, to destination: Int) {
        var ids = playlist.songIds
        ids.move(fromOffsets: source, toOffset: destination)
        playlist.songIds = ids
        playlist.dateModified = Date()
        saveContext()
    }
    
    // MARK: - Derived Collections
    
    func updateDerivedCollections() {
        // Update favorites
        favorites = songs.filter { $0.isFavorite }
        
        // Update recently played
        recentlyPlayed = songs
            .filter { $0.lastPlayedDate != nil }
            .sorted { ($0.lastPlayedDate ?? .distantPast) > ($1.lastPlayedDate ?? .distantPast) }
            .prefix(20)
            .map { $0 }
        
        // Update recently added
        recentlyAdded = songs
            .sorted { $0.dateAdded > $1.dateAdded }
            .prefix(20)
            .map { $0 }
        
        // Update albums
        let albumDict = Dictionary(grouping: songs) { $0.displayAlbum }
        albums = albumDict.compactMap { albumName, albumSongs in
            guard !albumName.isEmpty || albumName != "Unknown Album" else { return nil }
            let artist = albumSongs.first?.displayArtist ?? "Various Artists"
            let artwork = albumSongs.first(where: { $0.artworkData != nil })?.artworkData
            return Album(title: albumName, artist: artist, songs: albumSongs, artworkData: artwork)
        }
        .sorted()
        
        // Update artists
        let artistDict = Dictionary(grouping: songs) { $0.displayArtist }
        artists = artistDict.map { artistName, artistSongs in
            Artist(name: artistName, songs: artistSongs)
        }
        .sorted()
    }
    
    // MARK: - Search
    
    func search(query: String) -> (songs: [Song], albums: [Album], artists: [Artist], playlists: [Playlist]) {
        let lowercasedQuery = query.lowercased()
        
        let matchingSongs = songs.filter {
            $0.displayTitle.lowercased().contains(lowercasedQuery) ||
            $0.displayArtist.lowercased().contains(lowercasedQuery) ||
            $0.displayAlbum.lowercased().contains(lowercasedQuery)
        }
        
        let matchingAlbums = albums.filter {
            $0.title.lowercased().contains(lowercasedQuery) ||
            $0.displayArtist.lowercased().contains(lowercasedQuery)
        }
        
        let matchingArtists = artists.filter {
            $0.name.lowercased().contains(lowercasedQuery)
        }
        
        let matchingPlaylists = playlists.filter {
            $0.name.lowercased().contains(lowercasedQuery)
        }
        
        return (matchingSongs, matchingAlbums, matchingArtists, matchingPlaylists)
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        Task.detached {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    func getSongsForAlbum(_ album: Album) -> [Song] {
        return songs.filter { $0.displayAlbum == album.title }
            .sorted { $0.trackNumber < $1.trackNumber }
    }
    
    func getSongsForArtist(_ artist: Artist) -> [Song] {
        return songs.filter { $0.displayArtist == artist.name }
    }
}
