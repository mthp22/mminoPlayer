//
//  Playlist.swift
//  GreenWave
//
//  Playlist model for user-created playlists
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Playlist {
    @Attribute(.unique) var id: UUID
    var name: String
    var songIds: [UUID]
    var dateCreated: Date
    var dateModified: Date
    var artworkData: Data?
    
    var songs: [Song] {
        // This will be populated by the MusicLibrary
        []
    }
    
    var songCount: Int {
        songIds.count
    }
    
    var duration: Double {
        // Calculated by MusicLibrary
        0
    }
    
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, totalSeconds % 60)
        } else {
            return String(format: "%d:%02d", minutes, totalSeconds % 60)
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        songIds: [UUID] = [],
        dateCreated: Date = Date(),
        dateModified: Date = Date(),
        artworkData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.songIds = songIds
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.artworkData = artworkData
    }
}

// MARK: - Identifiable

extension Playlist: Identifiable {}

// MARK: - Hashable

extension Playlist: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Comparable

extension Playlist: Comparable {
    static func < (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}
