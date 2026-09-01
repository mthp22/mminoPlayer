//
//  Song.swift
//  GreenWave
//
//  Song model representing a single audio track in the library
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class Song {
    @Attribute(.unique) var id: UUID
    var title: String
    var artist: String
    var album: String
    var albumArtist: String
    var genre: String
    var trackNumber: Int32
    var discNumber: Int32
    var duration: Double
    var fileURL: String
    var dateAdded: Date
    var playCount: Int32
    var lastPlayedDate: Date?
    var isFavorite: Bool
    var artworkData: Data?
    
    // Computed properties
    var displayTitle: String {
        if title.isEmpty {
            return URL(fileURLWithPath: fileURL).deletingPathExtension().lastPathComponent
        }
        return title
    }
    
    var displayArtist: String {
        if artist.isEmpty {
            return "Unknown Artist"
        }
        return artist
    }
    
    var displayAlbum: String {
        if album.isEmpty {
            return "Unknown Album"
        }
        return album
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var localArtworkURL: URL? {
        guard !fileURL.isEmpty else { return nil }
        return URL(string: fileURL)
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        album: String,
        albumArtist: String = "",
        genre: String = "",
        trackNumber: Int32 = 0,
        discNumber: Int32 = 0,
        duration: Double,
        fileURL: String,
        dateAdded: Date = Date(),
        playCount: Int32 = 0,
        lastPlayedDate: Date? = nil,
        isFavorite: Bool = false,
        artworkData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.albumArtist = albumArtist
        self.genre = genre
        self.trackNumber = trackNumber
        self.discNumber = discNumber
        self.duration = duration
        self.fileURL = fileURL
        self.dateAdded = dateAdded
        self.playCount = playCount
        self.lastPlayedDate = lastPlayedDate
        self.isFavorite = isFavorite
        self.artworkData = artworkData
    }
}

// MARK: - Identifiable

extension Song: Identifiable {}

// MARK: - Hashable

extension Song: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Comparable

extension Song: Comparable {
    static func < (lhs: Song, rhs: Song) -> Bool {
        lhs.displayTitle.localizedCaseInsensitiveCompare(rhs.displayTitle) == .orderedAscending
    }
}
