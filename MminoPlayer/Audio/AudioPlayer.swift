//
//  AudioPlayer.swift
//  MminoPlayer
//
//  Centralized AVAudioPlayer playback manager

import Foundation
import AVFoundation
import SwiftUI
import Combine
import MediaPlayer

@MainActor
final class AudioPlayer: NSObject, ObservableObject {
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
    @Published var queueIndex: Int = -1
    
    // MARK: - Private Properties
    private var player: AVAudioPlayer?
    private var timer: Timer?
    private var nowPlayingManager: NowPlayingManager
    private var remoteCommandManager: RemoteCommandManager
    
    // For shuffle
    private var shuffledIndices: [Int] = []
    private var currentShuffleIndex: Int = 0
    
    // MARK: - Initialization
    private override init() {
        self.nowPlayingManager = NowPlayingManager.shared
        self.remoteCommandManager = RemoteCommandManager.shared
        
        super.init()
        setupRemoteCommands()
        configureAudioSession()
    }
    
    // MARK: - Public Methods
    
    func play(_ song: Song, in songs: [Song] = [], at index: Int = -1) {
        // Stop current playback
        stopTimer()
        player?.stop()
        
        // Set up queue
        if !songs.isEmpty {
            originalQueue = songs
            queue = songs
            queueIndex = index >= 0 ? index : songs.firstIndex(where: { $0.id == song.id }) ?? 0
            
            if shuffleEnabled {
                shuffleQueue(currentIndex: queueIndex)
            }
        } else {
            queue = [song]
            originalQueue = [song]
            queueIndex = 0
        }
        
        currentSong = song
        loadAndPlay(song: song)
        
        // Update play count
        song.incrementPlayCount()
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
        stopTimer()
        updateNowPlayingInfo(state: .paused)
    }
    
    func resume() {
        guard let player = player else { return }
        player.play()
        isPlaying = true
        startTimer()
        updateNowPlayingInfo(state: .playing)
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
        updateNowPlayingInfo(state: .stopped)
    }
    
    func skipToNext() {
        guard !queue.isEmpty else { return }
        
        var nextIndex: Int
        
        if shuffleEnabled {
            currentShuffleIndex += 1
            if currentShuffleIndex >= shuffledIndices.count {
                if repeatMode == .all {
                    currentShuffleIndex = 0
                } else {
                    stop()
                    return
                }
            }
            nextIndex = shuffledIndices[currentShuffleIndex]
        } else {
            nextIndex = queueIndex + 1
            
            if nextIndex >= queue.count {
                if repeatMode == .all {
                    nextIndex = 0
                } else if repeatMode == .one {
                    // Replay current song
                    seek(to: 0)
                    resume()
                    return
                } else {
                    stop()
                    return
                }
            }
        }
        
        queueIndex = nextIndex
        let nextSong = queue[nextIndex]
        play(nextSong, in: [], at: nextIndex)
    }
    
    func skipToPrevious() {
        guard let player = player, !queue.isEmpty else { return }
        
        // If more than 3 seconds into song, restart it
        if player.currentTime > 3 {
            seek(to: 0)
            return
        }
        
        var prevIndex: Int
        
        if shuffleEnabled {
            currentShuffleIndex -= 1
            if currentShuffleIndex < 0 {
                currentShuffleIndex = max(0, shuffledIndices.count - 1)
            }
            prevIndex = shuffledIndices[currentShuffleIndex]
        } else {
            prevIndex = queueIndex - 1
            
            if prevIndex < 0 {
                if repeatMode == .all {
                    prevIndex = queue.count - 1
                } else {
                    seek(to: 0)
                    return
                }
            }
        }
        
        queueIndex = prevIndex
        let prevSong = queue[prevIndex]
        play(prevSong, in: [], at: prevIndex)
    }
    
    func seek(to seconds: Double) {
        guard let player = player else { return }
        player.currentTime = seconds
        progress = seconds / duration
        updateNowPlayingInfo(elapsedTime: seconds)
    }
    
    func setVolume(_ volume: Float) {
        self.volume = volume
        player?.volume = volume
    }
    
    func addToQueue(_ song: Song) {
        if !queue.contains(where: { $0.id == song.id }) {
            queue.append(song)
        }
    }
    
    func removeFromQueue(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        queue.remove(at: index)
        
        // Adjust queueIndex if needed
        if index < queueIndex {
            queueIndex -= 1
        } else if index == queueIndex && index >= queue.count {
            // Removed current or future song
            if queueIndex >= queue.count {
                queueIndex = max(0, queue.count - 1)
            }
        }
    }
    
    func clearQueue() {
        guard let current = currentSong else { return }
        queue = [current]
        queueIndex = 0
        shuffledIndices = [0]
        currentShuffleIndex = 0
    }
    
    func reorderQueue(from source: IndexSet, to destination: Int) {
        var newQueue = queue
        newQueue.move(fromOffsets: source, toOffset: destination)
        
        // Don't move the currently playing song
        if source.contains(queueIndex) {
            return
        }
        
        queue = newQueue
        
        // Adjust queueIndex based on moves before it
        var offset = 0
        for index in source {
            if index < queueIndex {
                offset -= 1
            } else if index >= queueIndex {
                offset += 1
            }
        }
        queueIndex += offset
    }
    
    // MARK: - Private Methods
    
    private func loadAndPlay(song: Song) {
        guard let url = URL(string: song.fileURL) else {
            print("Invalid file URL: \(song.fileURL)")
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = volume
            player?.delegate = self
            
            duration = player?.duration ?? song.duration
            progress = 0
            
            player?.play()
            isPlaying = true
            
            startTimer()
            setupNowPlaying(for: song)
            updateNowPlayingInfo(state: .playing)
            
        } catch {
            print("Error loading audio: \(error.localizedDescription)")
            // Try next song in queue
            if queue.count > 1 {
                skipToNext()
            }
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
        guard let player = player, duration > 0 else { return }
        progress = player.currentTime / duration
        
        // Auto-advance when song ends
        if player.currentTime >= duration - 0.5 {
            skipToNext()
        }
    }
    
    private func setupNowPlaying(for song: Song) {
        nowPlayingManager.updateNowPlayingInfo(
            title: song.displayTitle,
            artist: song.displayArtist,
            album: song.displayAlbum,
            artworkData: song.artworkData,
            duration: song.duration,
            elapsedTime: 0
        )
    }
    
    private func updateNowPlayingInfo(state: PlaybackState? = nil, elapsedTime: Double? = nil) {
        var stateValue: PlaybackState? = state
        
        if state == nil {
            stateValue = isPlaying ? .playing : .paused
        }
        
        nowPlayingManager.updatePlaybackState(stateValue ?? (isPlaying ? .playing : .paused))
        
        if let elapsed = elapsedTime {
            nowPlayingManager.updateElapsedTime(elapsed)
        }
    }
    
    private func configureAudioSession() {
        AudioSessionManager.shared.configureForPlayback()
    }
    
    private func setupRemoteCommands() {
        remoteCommandManager.setupCommands(
            playHandler: { [weak self] in
                Task { @MainActor in
                    self?.resume()
                }
            },
            pauseHandler: { [weak self] in
                Task { @MainActor in
                    self?.pause()
                }
            },
            togglePlayPauseHandler: { [weak self] in
                Task { @MainActor in
                    self?.togglePlayPause()
                }
            },
            nextTrackHandler: { [weak self] in
                Task { @MainActor in
                    self?.skipToNext()
                }
            },
            previousTrackHandler: { [weak self] in
                Task { @MainActor in
                    self?.skipToPrevious()
                }
            },
            changePlaybackPositionHandler: { [weak self] position in
                Task { @MainActor in
                    self?.seek(to: position)
                }
            }
        )
    }
    
    private func shuffleQueue(currentIndex: Int) {
        shuffledIndices = Array(0..<queue.count).shuffled()
        
        // Ensure current song is first in shuffle order
        if let currentIndexInShuffled = shuffledIndices.firstIndex(of: currentIndex) {
            shuffledIndices.remove(at: currentIndexInShuffled)
            shuffledIndices.insert(currentIndex, at: 0)
        }
        
        currentShuffleIndex = 0
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            Task { @MainActor in
                skipToNext()
            }
        }
    }
    
    nonisolated func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Decode error: \(error?.localizedDescription ?? "Unknown")")
        Task { @MainActor in
            if queue.count > 1 {
                skipToNext()
            }
        }
    }
}
