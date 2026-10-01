//
//  FileImporter.swift
//  MminoPlayer
//
//  Handles file import from Files app

import Foundation
import SwiftUI
import UniformTypeIdentifiers

final class FileImporter {
    static let shared = FileImporter()
    
    // Supported audio types
    let supportedTypes: [UTType] = [
        .mp3,
        .mpeg4Audio,
        .wav,
        .aiff,
        UTType(filenameExtension: "flac") ?? .audio,
        UTType(filenameExtension: "ogg") ?? .audio,
        UTType(filenameExtension: "wma") ?? .audio,
        UTType(filenameExtension: "aac") ?? .audio
    ]
    
    private init() {}
    
    func importFile(from url: URL, to destinationDirectory: URL) async throws -> Song? {
        // Generate unique filename
        let fileExtension = url.pathExtension.lowercased()
        let uniqueID = UUID().uuidString
        let newFilename = "\(uniqueID).\(fileExtension)"
        
        let destinationURL = destinationDirectory.appendingPathComponent(newFilename)
        
        // Copy file to app's Documents directory
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        
        try FileManager.default.copyItem(at: url, to: destinationURL)
        
        // Extract metadata
        let metadataReader = MetadataReader.shared
        let metadata = try await metadataReader.readMetadata(from: destinationURL)
        
        // Create song model
        let song = Song(
            title: metadata.title ?? url.deletingPathExtension().lastPathComponent,
            artist: metadata.artist,
            album: metadata.album,
            albumArtist: metadata.albumArtist,
            genre: metadata.genre,
            trackNumber: metadata.trackNumber,
            discNumber: metadata.discNumber,
            duration: metadata.duration,
            fileURL: destinationURL.absoluteString,
            artworkData: metadata.artworkData
        )
        
        return song
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getApplicationSupportDirectory() -> URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func ensureMusicDirectory() -> URL {
        let baseDir = getApplicationSupportDirectory()
        let musicDir = baseDir.appendingPathComponent("Music", isDirectory: true)
        
        try? FileManager.default.createDirectory(at: musicDir, withIntermediateDirectories: true)
        
        return musicDir
    }
    
    func deleteSongFile(_ song: Song) {
        guard let url = URL(string: song.fileURL) else { return }
        
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - Metadata structure
struct AudioMetadata {
    var title: String?
    var artist: String?
    var album: String?
    var albumArtist: String?
    var genre: String?
    var trackNumber: Int32 = 0
    var discNumber: Int32 = 0
    var duration: Double = 0
    var year: Int32?
    var artworkData: Data?
}
