//
//  AudioPlayer.swift
//  GreenWave
//
//  Centralized audio playback manager using AVFoundation
//

import AVFoundation
import Combine
import MediaPlayer

@MainActor
final class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    
    // MARK: - Published Properties
    
    @Published private(set) var currentSong: Song?
    @Published private(set) var isPlaying = false
    @Published private(set) var progress: Double = 0
    @Published private(set) var duration: Double = 0
    @Published private(set) var volume: Float = 1.0
    
    @Published var shuffleEnabled = false
    @Published var repeatMode: RepeatMode = .off
    
    @Published var queue: [Song] = []
    @Published var originalQueue: [Song] = []
    
    // MARK: - Private Properties
    
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var nowPlayingManager = NowPlayingManager.shared
    private var remoteCommandManager = RemoteCommandManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    private init() {
        setupRemoteCommands()
        restorePlaybackState()
    }
    
    // MARK: - Public Methods
    
    func play(_ song: Song, inQueue: [Song] = []) {
        do {
            guard let url = URL(string: song.fileURL), FileManager.default.fileExists(atPath: url.path) else {
                print("File not found: \(song.fileURL)")
                return
            }
            
            // Stop current playback
            stopTimer()
            player?.stop()
            
            // Create new player
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.volume = volume
            player?.prepareToPlay()
            
            // Update state
            currentSong = song
            
            if !inQueue.isEmpty {
                originalQueue = inQueue
                queue = inQueue
                // Remove current song from queue if present
                queue.removeAll { $0.id == song.id }
            }
            
            // Start playback
            let success = player?.play() ?? false
            if success {
                isPlaying = true
                duration = player?.duration ?? song.duration
                startTimer()
                updateNowPlaying()
                updateRemoteCommands()
                
                // Update song play count
                Task.detached { [weak song] in
                    song?.playCount += 1
                    song?.lastPlayedDate = Date()
                }
            }
        } catch {
            print("Failed to play song: \(error)")
        }
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
        updateNowPlaying()
        updateRemoteCommands()
    }
    
    func resume() {
        player?.play()
        isPlaying = true
        startTimer()
        updateNowPlaying()
        updateRemoteCommands()
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    func stop() {
        player?.stop()
        isPlaying = false
        progress = 0
        stopTimer()
        updateNowPlaying()
    }
    
    func next() {
        guard !queue.isEmpty else { return }
        
        let nextSong: Song
        if shuffleEnabled {
            nextSong = queue.randomElement()!
        } else {
            nextSong = queue.removeFirst()
        }
        
        play(nextSong, inQueue: queue)
    }
    
    func previous() {
        // If more than 3 seconds into the song, restart it
        if progress > 3 {
            seek(to: 0)
            return
        }
        
        // Go to previous song in queue
        guard !originalQueue.isEmpty,
              let currentIndex = originalQueue.firstIndex(where: { $0.id == currentSong?.id }),
              currentIndex > 0 else {
            return
        }
        
        let previousSong = originalQueue[currentIndex - 1]
        play(previousSong, inQueue: Array(originalQueue.dropFirst(currentIndex)))
    }
    
    func seek(to seconds: Double) {
        player?.currentTime = seconds
        progress = seconds
        updateNowPlaying()
    }
    
    func skipForward(by seconds: Double) {
        let newTime = min(progress + seconds, duration)
        seek(to: newTime)
    }
    
    func skipBackward(by seconds: Double) {
        let newTime = max(progress - seconds, 0)
        seek(to: newTime)
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
        player?.volume = volume
    }
    
    func addToQueue(_ song: Song) {
        queue.append(song)
    }
    
    func removeFromQueue(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        queue.remove(at: index)
    }
    
    func clearQueue() {
        queue.removeAll()
        originalQueue.removeAll()
    }
    
    func playNext(_ song: Song) {
        queue.insert(song, at: 0)
    }
    
    // MARK: - Private Methods
    
    private func setupRemoteCommands() {
        remoteCommandManager.onPlay = { [weak self] in
            self?.resume()
        }
        
        remoteCommandManager.onPause = { [weak self] in
            self?.pause()
        }
        
        remoteCommandManager.onNextTrack = { [weak self] in
            self?.next()
        }
        
        remoteCommandManager.onPreviousTrack = { [weak self] in
            self?.previous()
        }
        
        remoteCommandManager.onSeek = { [weak self] seconds in
            self?.seek(to: self!.progress + seconds)
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateProgress()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateProgress() {
        guard let player = player, isPlaying else { return }
        
        progress = player.currentTime
        duration = player.duration
        
        updateNowPlaying()
        
        // Check for song completion
        if progress >= duration && duration > 0 {
            handleSongCompletion()
        }
    }
    
    private func handleSongCompletion() {
        switch repeatMode {
        case .one:
            seek(to: 0)
            resume()
        case .all, .off:
            if !queue.isEmpty {
                next()
            } else if repeatMode == .all && !originalQueue.isEmpty {
                // Restart from beginning
                if let firstSong = originalQueue.first {
                    play(firstSong, inQueue: Array(originalQueue.dropFirst()))
                }
            } else {
                // End of queue
                pause()
            }
        }
    }
    
    private func updateNowPlaying() {
        nowPlayingManager.updateNowPlaying(
            song: currentSong,
            isPlaying: isPlaying,
            currentTime: progress,
            duration: duration
        )
    }
    
    private func updateRemoteCommands() {
        remoteCommandManager.updateCommandStates(
            isPlaying: isPlaying,
            isFavorite: currentSong?.isFavorite ?? false
        )
    }
    
    private func restorePlaybackState() {
        // Restore last playback state from UserDefaults
        if let savedProgress = UserDefaults.standard.value(forKey: "playbackProgress") as? Double {
            progress = savedProgress
        }
        if let savedVolume = UserDefaults.standard.value(forKey: "playbackVolume") as? Float {
            volume = savedVolume
        }
        shuffleEnabled = UserDefaults.standard.bool(forKey: "shuffleEnabled")
        if let rawRepeatMode = UserDefaults.standard.value(forKey: "repeatMode") as? Int {
            repeatMode = RepeatMode(rawValue: rawRepeatMode) ?? .off
        }
    }
    
    func savePlaybackState() {
        UserDefaults.standard.set(progress, forKey: "playbackProgress")
        UserDefaults.standard.set(volume, forKey: "playbackVolume")
        UserDefaults.standard.set(shuffleEnabled, forKey: "shuffleEnabled")
        UserDefaults.standard.set(repeatMode.rawValue, forKey: "repeatMode")
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            Task { @MainActor in
                handleSongCompletion()
            }
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print("Decode error: \(error)")
        }
        Task { @MainActor in
            pause()
        }
    }
}
