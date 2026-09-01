//
//  AudioSessionManager.swift
//  GreenWave
//
//  Manages AVAudioSession configuration for background playback
//

import AVFoundation
import Combine

@MainActor
final class AudioSessionManager: ObservableObject {
    static let shared = AudioSessionManager()
    
    private init() {
        setupAudioSession()
        setupInterruptListener()
    }
    
    // MARK: - Public Methods
    
    func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .mediaPlayback,
                options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP]
            )
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func handleInterruption(type: AVAudioSession.InterruptionType) {
        switch type {
        case .began:
            // Audio interruption began (e.g., incoming call)
            NotificationCenter.default.post(name: .audioInterruptionBegan, object: nil)
            
        case .ended:
            // Audio interruption ended
            NotificationCenter.default.post(name: .audioInterruptionEnded, object: nil)
            
        @unknown default:
            break
        }
    }
    
    private func setupInterruptListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        handleInterruption(type: type)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let audioInterruptionBegan = Notification.Name("audioInterruptionBegan")
    static let audioInterruptionEnded = Notification.Name("audioInterruptionEnded")
}
