//
//  MetadataReader.swift
//  MminoPlayer
//
//  Extracts metadata from audio files using AVFoundation

import Foundation
import AVFoundation
import SwiftUI

final class MetadataReader {
    static let shared = MetadataReader()
    
    private init() {}
    
    func readMetadata(from url: URL) async throws -> AudioMetadata {
        let asset = AVAsset(url: url)
        
        var metadata = AudioMetadata()
        
        // Get duration
        metadata.duration = CMTimeGetSeconds(asset.duration)
        
        do {
            // Load common metadata
            let commonMetadata = try await asset.load(.commonMetadata)
            
            for item in commonMetadata {
                let key = try await item.key() as? String ?? ""
                
                switch key.lowercased() {
                case "title", "tit2":
                    if let value = try? await item.load(.stringValue), !value.isEmpty {
                        metadata.title = value
                    }
                    
                case "artist", "tpe1":
                    if let value = try? await item.load(.stringValue), !value.isEmpty {
                        metadata.artist = value
                    }
                    
                case "album", "talb":
                    if let value = try? await item.load(.stringValue), !value.isEmpty {
                        metadata.album = value
                    }
                    
                case "albumartist", "tpe2":
                    if let value = try? await item.load(.stringValue), !value.isEmpty {
                        metadata.albumArtist = value
                    }
                    
                case "genre", "tcon":
                    if let value = try? await item.load(.stringValue), !value.isEmpty {
                        metadata.genre = value
                    }
                    
                case "tracknumber", "trck":
                    if let value = try? await item.load(.stringValue) {
                        metadata.trackNumber = Int32(value.replacingOccurrences(of: "/", with: "")) ?? 0
                    }
                    
                case "discnumber", "tpos":
                    if let value = try? await item.load(.stringValue) {
                        metadata.discNumber = Int32(value.replacingOccurrences(of: "/", with: "")) ?? 0
                    }
                    
                case "year", "date":
                    if let value = try? await item.load(.stringValue), let year = Int32(value.prefix(4)) {
                        metadata.year = year
                    }
                    
                default:
                    break
                }
            }
            
            // Try to extract artwork
            metadata.artworkData = try await extractArtwork(from: asset)
            
        } catch {
            print("Error reading metadata: \(error.localizedDescription)")
        }
        
        return metadata
    }
    
    private func extractArtwork(from asset: AVAsset) async throws -> Data? {
        let metadata = try await asset.load(.metadata)
        
        for item in metadata {
            let keySpace = item.keySpace
            
            if keySpace == .common || keySpace == .id3 {
                let key = try? await item.load(.key) as? String
                
                if key == "artwork" || key == "APIC" {
                    return try await item.load(.dataRepresentation)
                }
            }
        }
        
        return nil
    }
}
