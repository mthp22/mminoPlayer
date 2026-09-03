//
//  NowPlayingManager.swift
//  GreenWave
//
//  Manages MPNowPlayingInfoCenter for Lock Screen and Control Center integration
//

import MediaPlayer
import AVFoundation

@MainActor
final class NowPlayingManager {
    static let shared = NowPlayingManager()
    
    private init() {}
    
    // MARK: - Public Methods
    
    func updateNowPlaying(song: Song?, isPlaying: Bool, currentTime: Double, duration: Double) {
        let nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        var updatedInfo = nowPlayingInfo
        
        if let song = song {
            // Set media item info
            updatedInfo[MPMediaItemPropertyTitle] = song.displayTitle
            updatedInfo[MPMediaItemPropertyArtist] = song.displayArtist
            updatedInfo[MPMediaItemPropertyAlbumTitle] = song.displayAlbum
            updatedInfo[MPMediaItemPropertyGenre] = song.genre.isEmpty ? nil : song.genre
            updatedInfo[MPMediaItemPropertyPlaybackDuration] = duration
            updatedInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            
            // Set artwork if available
            if let artworkData = song.artworkData,
               let image = UIImage(data: artworkData) {
                updatedInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(
                    boundsSize: image.size,
                    requestHandler: { _ in image }
                )
            } else {
                updatedInfo[MPMediaItemPropertyArtwork] = nil
            }
            
            // Set album artist if available
            if !song.albumArtist.isEmpty {
                updatedInfo[MPMediaItemPropertyAlbumArtist] = song.albumArtist
            }
            
            // Set track number if available
            if song.trackNumber > 0 {
                updatedInfo[MPMediaItemPropertyTrackNumber] = song.trackNumber
            }
            
            if song.discNumber > 0 {
                updatedInfo[MPMediaItemPropertyDiscNumber] = song.discNumber
            }
        }
        
        // Set playback rate
        updatedInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        // Update the now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = updatedInfo
    }
    
    func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}
