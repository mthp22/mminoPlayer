//
//  Playlist.swift
//  MminoPlayer
//
//  User playlist model with SwiftData persistence

import Foundation
import SwiftData

@Model
final class Playlist {
    var id: UUID
    var name: String
    var songIDs: [UUID]
    var dateCreated: Date
    var dateModified: Date
    
    // Computed properties (not persisted)
    @Transient var songs: [Song] = []
    
    init(
        id: UUID = UUID(),
        name: String,
        songIDs: [UUID] = [],
        dateCreated: Date = Date(),
        dateModified: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.songIDs = songIDs
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
    
    var songCount: Int {
        songIDs.count
    }
    
    var duration: TimeInterval {
        songs.reduce(0) { $0 + $1.duration }
    }
    
    var formattedDuration: String {
        formatDuration(duration)
    }
    
    var hasSongs: Bool {
        !songIDs.isEmpty
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
    
    func addSong(_ song: Song) {
        if !songIDs.contains(song.id) {
            songIDs.append(song.id)
            dateModified = Date()
        }
    }
    
    func removeSong(_ song: Song) {
        if let index = songIDs.firstIndex(of: song.id) {
            songIDs.remove(at: index)
            dateModified = Date()
        }
    }
    
    func reorderSong(from source: IndexSet, to destination: Int) {
        var ids = songIDs
        ids.move(fromOffsets: source, toOffset: destination)
        songIDs = ids
        dateModified = Date()
    }
}

// MARK: - Equatable & Hashable
extension Playlist: Equatable, Hashable {
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Identifiable
extension Playlist: Identifiable {}
