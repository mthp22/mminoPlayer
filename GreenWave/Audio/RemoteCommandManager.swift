//
//  RemoteCommandManager.swift
//  GreenWave
//
//  Manages MPRemoteCommandCenter for Lock Screen and Control Center controls
//

import MediaPlayer
import Combine

@MainActor
final class RemoteCommandManager: ObservableObject {
    static let shared = RemoteCommandManager()
    
    private let commandCenter = MPRemoteCommandCenter.shared()
    private var cancellables = Set<AnyCancellable>()
    
    // Callbacks
    var onPlay: (() -> Void)?
    var onPause: (() -> Void)?
    var onNextTrack: (() -> Void)?
    var onPreviousTrack: (() -> Void)?
    var onSeek: ((Double) -> Void)?
    var onToggleFavorite: (() -> Void)?
    
    private init() {
        setupCommands()
    }
    
    // MARK: - Public Methods
    
    func setupCommands() {
        // Play command
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.onPlay?()
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.onPause?()
            return .success
        }
        
        // Toggle play/pause command
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            if let isPlaying = self?.isPlaying {
                if isPlaying {
                    self?.onPause?()
                } else {
                    self?.onPlay?()
                }
            }
            return .success
        }
        
        // Next track command
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.onNextTrack?()
            return .success
        }
        
        // Previous track command
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.onPreviousTrack?()
            return .success
        }
        
        // Seek command
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekForwardCommand.addTarget { [weak self] event in
            guard let event = event as? MPSeekCommandEvent else { return .commandFailed }
            if event.type == .beginSeekingForward || event.type == .endSeekingForward {
                self?.onSeek?(10) // Skip forward 10 seconds
            }
            return .success
        }
        
        commandCenter.seekBackwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.addTarget { [weak self] event in
            guard let event = event as? MPSeekCommandEvent else { return .commandFailed }
            if event.type == .beginSeekingBackward || event.type == .endSeekingBackward {
                self?.onSeek?(-10) // Skip backward 10 seconds
            }
            return .success
        }
        
        // Change playback position command
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.onSeek?(event.positionTime)
            return .success
        }
    }
    
    func updateCommandStates(isPlaying: Bool, isFavorite: Bool) {
        self.isPlaying = isPlaying
        
        commandCenter.playCommand.isEnabled = !isPlaying
        commandCenter.pauseCommand.isEnabled = isPlaying
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.seekForwardCommand.isEnabled = true
        commandCenter.seekBackwardCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true
    }
    
    private var isPlaying: Bool = false
}
