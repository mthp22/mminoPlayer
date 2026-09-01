//
//  Artist.swift
//  GreenWave
//
//  Artist model representing a music artist
//

import Foundation
import SwiftUI

struct Artist: Identifiable, Hashable {
    let id: UUID
    let name: String
    let songs: [Song]
    
    var albumCount: Int {
        Set(songs.map { $0.displayAlbum }).count
    }
    
    var songCount: Int {
        songs.count
    }
    
    var artworkData: Data? {
        // Return artwork from first song with artwork
        songs.first(where: { $0.artworkData != nil })?.artworkData
    }
    
    init(id: UUID = UUID(), name: String, songs: [Song]) {
        self.id = id
        self.name = name
        self.songs = songs
    }
}

// MARK: - Comparable

extension Artist: Comparable {
    static func < (lhs: Artist, rhs: Artist) -> Bool {
        lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
    }
}
