//
//  AudioSessionManager.swift
//  MminoPlayer
//
//  Configures AVAudioSession for background playback

import Foundation
import AVFoundation

final class AudioSessionManager {
    static let shared = AudioSessionManager()
    
    private init() {
        setupAudioSession()
    }
    
    func configureForPlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .mediaPlayback,
                options: [.allowBluetooth, .allowBluetoothA2DP, .allowAirPlay]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    private func setupAudioSession() {
        // Register for audio session interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMediaServicesReset),
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: nil
        )
    }
    
    @objc private func handleAudioSessionInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began, pause playback
            Task { @MainActor in
                AudioPlayer.shared.pause()
            }
            
        case .ended:
            // Interruption ended, resume if it was a phone call
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) {
                Task { @MainActor in
                    AudioPlayer.shared.resume()
                }
            }
            
        @unknown default:
            break
        }
    }
    
    @objc private func handleMediaServicesReset() {
        // Media services were reset, reconfigure audio session
        configureForPlayback()
    }
}
