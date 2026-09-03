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
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let asset = AVAsset(url: url)
                    
                    // Load required metadata asynchronously
                    let group = DispatchGroup()
                    group.enter()
                    
                    var metadata = AudioMetadata()
                    
                    // Get duration
                    metadata.duration = CMTimeGetSeconds(asset.duration)
                    
                    // Load common metadata
                    Task.detached {
                        do {
                            let commonMetadata = try await asset.load(.commonMetadata)
                            
                            for item in commonMetadata {
                                let key = (try? await item.key())?.lowercased() ?? ""
                                
                                switch key {
                                case "title", "tit2":
                                    if let value = try? await item.stringValue, !value.isEmpty {
                                        metadata.title = value
                                    }
                                    
                                case "artist", "tpe1":
                                    if let value = try? await item.stringValue, !value.isEmpty {
                                        metadata.artist = value
                                    }
                                    
                                case "album", "talb":
                                    if let value = try? await item.stringValue, !value.isEmpty {
                                        metadata.album = value
                                    }
                                    
                                case "albumartist", "tpe2":
                                    if let value = try? await item.stringValue, !value.isEmpty {
                                        metadata.albumArtist = value
                                    }
                                    
                                case "genre", "tcon":
                                    if let value = try? await item.stringValue, !value.isEmpty {
                                        metadata.genre = value
                                    }
                                    
                                case "tracknumber", "trck":
                                    if let value = try? await item.stringValue {
                                        metadata.trackNumber = Int32(value.replacingOccurrences(of: "/", with: "")) ?? 0
                                    }
                                    
                                case "discnumber", "tpos":
                                    if let value = try? await item.stringValue {
                                        metadata.discNumber = Int32(value.replacingOccurrences(of: "/", with: "")) ?? 0
                                    }
                                    
                                case "year", "date":
                                    if let value = try? await item.stringValue, let year = Int32(value.prefix(4)) {
                                        metadata.year = year
                                    }
                                    
                                default:
                                    break
                                }
                            }
                            
                            // Try to extract artwork
                            metadata.artworkData = try await self.extractArtwork(from: asset)
                            
                        } catch {
                            print("Error reading metadata: \(error.localizedDescription)")
                        }
                        
                        group.leave()
                    }
                    
                    group.notify(queue: .main) {
                        continuation.resume(returning: metadata)
                    }
                    
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func extractArtwork(from asset: AVAsset) async throws -> Data? {
        guard #available(iOS 17.0, *) else {
            // Fallback for iOS 16
            return try await extractArtworkLegacy(from: asset)
        }
        
        let artworkMetadata = try await asset.load(.artwork)
        
        guard let imageData = artworkMetadata?.first?.dataRepresentation else {
            return nil
        }
        
        return imageData
    }
    
    @available(iOS, deprecated: 17.0, message: "Use extractArtwork(from:) instead")
    private func extractArtworkLegacy(from asset: AVAsset) async throws -> Data? {
        let metadata = try await asset.load(.metadata)
        
        for item in metadata {
            let keySpace = try await item.keySpace
            
            if keySpace == .common || keySpace == .id3 {
                let key = try? await item.key() as String
                
                if key == "artwork" || key == "APIC" {
                    return try await item.load(.dataRepresentation)
                }
            }
        }
        
        return nil
    }
}
