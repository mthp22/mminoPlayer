//
//  FileImporter.swift
//  GreenWave
//
//  Handles importing audio files from the Files app
//

import Foundation
import UniformTypeIdentifiers

struct FileImporter {
    static let shared = FileImporter()
    
    // Supported audio UTTypes
    let supportedTypes: [UTType] = [
        .mp3,
        .mpeg4Audio,
        .wav,
        .aiff,
        .audioInterchangeFileFormat
    ]
    
    private init() {}
    
    // MARK: - Public Methods
    
    func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func getAppSupportDirectory() -> URL {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        // Create directory if it doesn't exist
        try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        
        return appSupportURL.appendingPathComponent("Music", isDirectory: true)
    }
    
    func copyFileToAppSupport(from sourceURL: URL) async throws -> URL {
        let musicDirectory = getAppSupportDirectory()
        
        // Generate unique filename
        let fileExtension = sourceURL.pathExtension
        let uniqueID = UUID().uuidString
        let destinationURL = musicDirectory.appendingPathComponent("\(uniqueID).\(fileExtension)")
        
        // Copy the file
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        
        return destinationURL
    }
    
    func validateAudioFile(at url: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        
        // Check file extension
        let validExtensions = ["mp3", "m4a", "aac", "wav", "aiff", "aif", "flac"]
        let fileExtension = url.pathExtension.lowercased()
        
        return validExtensions.contains(fileExtension)
    }
    
    func getFileSize(at url: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
}

// MARK: - UTType Extension

extension UTType {
    static var mp3: UTType {
        UTType(filenameExtension: "mp3") ?? .audio
    }
    
    static var mpeg4Audio: UTType {
        UTType(filenameExtension: "m4a") ?? .audio
    }
    
    static var wav: UTType {
        UTType(filenameExtension: "wav") ?? .audio
    }
    
    static var aiff: UTType {
        UTType(filenameExtension: "aiff") ?? .audio
    }
    
    static var audioInterchangeFileFormat: UTType {
        UTType(filenameExtension: "aif") ?? .audio
    }
    
    static var flac: UTType {
        UTType(filenameExtension: "flac") ?? .audio
    }
}
