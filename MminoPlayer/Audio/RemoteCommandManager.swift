//
//  RemoteCommandManager.swift
//  MminoPlayer
//
//  Handles remote commands from Lock Screen, Control Center, and accessories

import Foundation
import MediaPlayer

final class RemoteCommandManager {
    static let shared = RemoteCommandManager()
    
    private init() {}
    
    func setupCommands(
        playHandler: @escaping () -> Void,
        pauseHandler: @escaping () -> Void,
        togglePlayPauseHandler: @escaping () -> Void,
        nextTrackHandler: @escaping () -> Void,
        previousTrackHandler: @escaping () -> Void,
        changePlaybackPositionHandler: @escaping (Double) -> Void
    ) {
        let commandCenter = MPRemoteCommandCenter.default()
        
        // Enable/disable commands
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        
        // Disable unsupported commands
        commandCenter.skipForwardCommand.isEnabled = false
        commandCenter.skipBackwardCommand.isEnabled = false
        commandCenter.changeRepeatModeCommand.isEnabled = false
        commandCenter.changeShuffleModeCommand.isEnabled = false
        commandCenter.ratingCommand.isEnabled = false
        commandCenter.likeCommand.isEnabled = false
        commandCenter.dislikeCommand.isEnabled = false
        commandCenter.bookmarkCommand.isEnabled = false
        commandCenter.seekForwardCommand.isEnabled = false
        commandCenter.seekBackwardCommand.isEnabled = false
        commandCenter.changePlaybackRateCommand.isEnabled = false
        
        // Add targets
        commandCenter.playCommand.addTarget { event in
            playHandler()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { event in
            pauseHandler()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { event in
            togglePlayPauseHandler()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { event in
            nextTrackHandler()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { event in
            previousTrackHandler()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            changePlaybackPositionHandler(positionEvent.positionTime)
            return .success
        }
    }
}
