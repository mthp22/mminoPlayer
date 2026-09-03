//
//  Album.swift
//  MminoPlayer
//
//  Album aggregation model

import Foundation
import SwiftData
import SwiftUI

struct Album: Identifiable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let year: Int32?
    let genre: String?
    let artworkData: Data?
    let songIDs: [UUID]
    
    var songs: [Song] = []
    
    init(id: UUID = UUID(), title: String, artist: String, year: Int32? = nil, genre: String? = nil, artworkData: Data? = nil, songIDs: [UUID] = []) {
        self.id = id
        self.title = title
        self.artist = artist
        self.year = year
        self.genre = genre
        self.artworkData = artworkData
        self.songIDs = songIDs
    }
    
    var displayTitle: String {
        title.isEmpty ? "Unknown Album" : title
    }
    
    var displayArtist: String {
        artist.isEmpty ? "Various Artists" : artist
    }
    
    var hasArtwork: Bool {
        artworkData != nil
    }
    
    var duration: TimeInterval {
        songs.reduce(0) { $0 + $1.duration }
    }
    
    var formattedDuration: String {
        formatDuration(duration)
    }
    
    var trackCount: Int {
        songs.count
    }
    
    private func formatDuration(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else {
            return "0:00"
        }
        
        let hours = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, mins, secs)
        }
        return String(format: "%d:%02d", mins, secs)
    }
    
    static func == (lhs: Album, rhs: Album) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Album fetching from Song models
extension Album {
    static func fetchAlbums(from songs: [Song]) -> [Album] {
        // Group songs by album
        var albumDict: [String: [Song]] = [:]
        
        for song in songs {
            let albumKey = "\(song.displayAlbum)|\(song.albumArtist ?? song.displayArtist)"
            albumDict[albumKey, default: []].append(song)
        }
        
        // Convert to Album objects
        return albumDict.compactMap { key, songs in
            guard !songs.isEmpty else { return nil }
            
            let firstSong = songs.first!
            let sortedSongs = songs.sorted { ($0.trackNumber, $0.discNumber) < ($1.trackNumber, $1.discNumber) }
            
            return Album(
                title: firstSong.displayAlbum,
                artist: firstSong.albumArtist ?? firstSong.displayArtist,
                year: nil,
                genre: firstSong.genre,
                artworkData: sortedSongs.first(where: { $0.artworkData != nil })?.artworkData,
                songIDs: sortedSongs.map { $0.id }
            )
        }.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }
}
