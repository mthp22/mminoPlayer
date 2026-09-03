//
//  MetadataReader.swift
//  GreenWave
//
//  Reads metadata from audio files using AVFoundation
//

import Foundation
import AVFoundation
import MediaPlayer

struct MetadataReader {
    static let shared = MetadataReader()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func readMetadata(from url: URL) async -> (title: String, artist: String, album: String, albumArtist: String, genre: String, trackNumber: Int32, discNumber: Int32, duration: Double, artworkData: Data?) {
        do {
            let asset = AVAsset(url: url)
            
            // Load metadata asynchronously
            try await asset.load(.metadata, .duration)
            
            var title = ""
            var artist = ""
            var album = ""
            var albumArtist = ""
            var genre = ""
            var trackNumber: Int32 = 0
            var discNumber: Int32 = 0
            var artworkData: Data? = nil
            
            // Parse metadata
            for item in asset.metadata {
                guard let key = item.commonKey?.rawValue else { continue }
                
                switch key {
                case "title":
                    title = await getStringValue(from: item) ?? ""
                case "artist":
                    artist = await getStringValue(from: item) ?? ""
                case "albumName":
                    album = await getStringValue(from: item) ?? ""
                case "albumArtist":
                    albumArtist = await getStringValue(from: item) ?? ""
                case "genre":
                    genre = await getStringValue(from: item) ?? ""
                case "trackNumber":
                    trackNumber = await getIntValue(from: item) ?? 0
                case "discNumber":
                    discNumber = await getIntValue(from: item) ?? 0
                case "artwork":
                    artworkData = await getArtworkData(from: item)
                default:
                    break
                }
            }
            
            // Fall back to filename if title is empty
            if title.isEmpty {
                title = url.deletingPathExtension().lastPathComponent
            }
            
            let duration = CMTimeGetSeconds(asset.duration)
            
            return (title, artist, album, albumArtist, genre, trackNumber, discNumber, duration, artworkData)
        } catch {
            print("Failed to read metadata: \(error)")
            
            // Fall back to filename
            let fallbackTitle = url.deletingPathExtension().lastPathComponent
            
            return (fallbackTitle, "", "", "", "", 0, 0, 0, nil)
        }
    }
    
    // MARK: - Private Methods
    
    private func getStringValue(from item: AVMetadataItem) async -> String? {
        do {
            return try await item.getStringValue()
        } catch {
            return nil
        }
    }
    
    private func getIntValue(from item: AVMetadataItem) async -> Int32? {
        do {
            if let stringValue = try await item.getStringValue(),
               let intValue = Int32(stringValue) {
                return intValue
            }
            return nil
        } catch {
            return nil
        }
    }
    
    private func getArtworkData(from item: AVMetadataItem) async -> Data? {
        do {
            if let dataValue = try await item.getDataValue() {
                return dataValue
            }
            return nil
        } catch {
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    func createSong(from url: URL, metadata: (title: String, artist: String, album: String, albumArtist: String, genre: String, trackNumber: Int32, discNumber: Int32, duration: Double, artworkData: Data?)) -> Song {
        return Song(
            id: UUID(),
            title: metadata.title,
            artist: metadata.artist,
            album: metadata.album,
            albumArtist: metadata.albumArtist,
            genre: metadata.genre,
            trackNumber: metadata.trackNumber,
            discNumber: metadata.discNumber,
            duration: metadata.duration,
            fileURL: url.absoluteString,
            dateAdded: Date(),
            playCount: 0,
            lastPlayedDate: nil,
            isFavorite: false,
            artworkData: metadata.artworkData
        )
    }
}
