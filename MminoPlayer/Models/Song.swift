//
//  Song.swift
//  MminoPlayer
//
//  Core song model with SwiftData persistence

import Foundation
import SwiftData
import SwiftUI

@Model
final class Song {
    var id: UUID
    var title: String
    var artist: String?
    var album: String?
    var albumArtist: String?
    var genre: String?
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
        if !title.isEmpty {
            return title
        }
        // Fallback to filename without extension
        let url = URL(fileURLWithPath: fileURL)
        return url.deletingPathExtension().lastPathComponent
    }
    
    var displayArtist: String {
        artist ?? "Unknown Artist"
    }
    
    var displayAlbum: String {
        album ?? "Unknown Album"
    }
    
    var formattedDuration: String {
        formatDuration(duration)
    }
    
    var hasArtwork: Bool {
        artworkData != nil
    }
    
    init(
        id: UUID = UUID(),
        title: String,
        artist: String? = nil,
        album: String? = nil,
        albumArtist: String? = nil,
        genre: String? = nil,
        trackNumber: Int32 = 0,
        discNumber: Int32 = 0,
        duration: Double = 0,
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
    
    private func formatDuration(_ seconds: Double) -> String {
        guard seconds.isFinite && seconds >= 0 else {
            return "0:00"
        }
        
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }
    
    func incrementPlayCount() {
        playCount += 1
        lastPlayedDate = Date()
    }
}
