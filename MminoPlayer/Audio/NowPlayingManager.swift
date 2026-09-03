//
//  NowPlayingManager.swift
//  MminoPlayer
//
//  Updates Now Playing Info Center for Lock Screen and Control Center

import Foundation
import MediaPlayer
import SwiftUI

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
    
    func updatePlaybackState(_ state: AVAudioSession.PlaybackState) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        
        // Update playback rate based on state
        var info = nowPlayingInfoCenter.nowPlayingInfo ?? [:]
        
        switch state {
        case .playing:
            info[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        case .paused, .interrupted:
            info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
        case .stopped:
            info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        @unknown default:
            info[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
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
