//
//  NowPlayingManager.swift
//  MminoPlayer
//
//  Updates Now Playing Info Center for Lock Screen and Control Center

import Foundation
import MediaPlayer
import SwiftUI

/// Custom playback state enum to avoid AVAudioSession.PlaybackState dependency
enum PlaybackState: Int, CaseIterable {
    case stopped = 0
    case playing = 1
    case paused = 2
    case interrupted = 3
}

final class NowPlayingManager {
    static let shared = NowPlayingManager()
    
    private init() {}
    
    func updateNowPlayingInfo(
        title: String,
        artist: String,
        album: String?,
        artworkData: Data?,
        duration: Double,
        elapsedTime: Double
    ) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime,
            MPNowPlayingInfoPropertyPlaybackRate: 1.0
        ]
        
        if let album = album {
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
        }
        
        // Set artwork
        if let imageData = artworkData, let image = UIImage(data: imageData) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    func updatePlaybackState(_ state: PlaybackState) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        
        // Update playback rate based on state
        var info = nowPlayingInfoCenter.nowPlayingInfo ?? [:]
        
        switch state {
        case .playing:
            info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        case .paused, .interrupted, .stopped:
            info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        }
        
        if state == .stopped {
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        }
        
        nowPlayingInfoCenter.nowPlayingInfo = info
    }
    
    func updateElapsedTime(_ time: Double) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var info = nowPlayingInfoCenter.nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        nowPlayingInfoCenter.nowPlayingInfo = info
    }
    
    func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}
