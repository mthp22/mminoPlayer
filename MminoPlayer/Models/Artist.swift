//
//  Artist.swift
//  MminoPlayer
//
//  Artist aggregation model

import Foundation
import SwiftUI

struct Artist: Identifiable, Hashable {
    let id: UUID
    let name: String
    let songIDs: [UUID]
    
    var songs: [Song] = []
    var albums: [Album] = []
    
    init(id: UUID = UUID(), name: String, songIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.songIDs = songIDs
    }
    
    var displayName: String {
        name.isEmpty ? "Unknown Artist" : name
    }
    
    var songCount: Int {
        songs.count
    }
    
    var albumCount: Int {
        Set(songs.compactMap { $0.album }).count
    }
    
    static func == (lhs: Artist, rhs: Artist) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Artist fetching from Song models
extension Artist {
    static func fetchArtists(from songs: [Song]) -> [Artist] {
        // Group songs by artist
        var artistDict: [String: [Song]] = [:]
        
        for song in songs {
            let artistKey = song.displayArtist
            artistDict[artistKey, default: []].append(song)
        }
        
        // Convert to Artist objects
        return artistDict.compactMap { name, songs in
            guard !songs.isEmpty else { return nil }
            
            return Artist(
                name: name,
                songIDs: songs.map { $0.id }
            )
        }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
