//
//  Album.swift
//  GreenWave
//
//  Album model representing a collection of songs
//

import Foundation
import SwiftUI

struct Album: Identifiable, Hashable {
    let id: UUID
    let title: String
    let artist: String
    let songs: [Song]
    let artworkData: Data?
    
    var displayArtist: String {
        if artist.isEmpty {
            return "Various Artists"
        }
        return artist
    }
    
    var year: Int? {
        // Could extract from song metadata if available
        nil
    }
    
    var duration: Double {
        songs.reduce(0) { $0 + $1.duration }
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
    
    var songCount: Int {
        songs.count
    }
    
    init(id: UUID = UUID(), title: String, artist: String, songs: [Song], artworkData: Data? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.songs = songs
        self.artworkData = artworkData
    }
}

// MARK: - Comparable

extension Album: Comparable {
    static func < (lhs: Album, rhs: Album) -> Bool {
        lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
    }
}
