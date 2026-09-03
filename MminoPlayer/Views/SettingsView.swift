//
//  SettingsView.swift
//  MminoPlayer
//
//  App settings and preferences

import SwiftUI

struct SettingsView: View {
    @ObservedObject var audioPlayer: AudioPlayer
    @StateObject private var library = MusicLibrary.shared
    
    @State private var sleepTimerDuration: Double = 0
    @State private var showingSleepTimer = false
    @State private var audioQuality: AudioQuality = .high
    @State private var showLyrics = true
    @State private var useCellularData = false
    
    enum AudioQuality: String, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var description: String {
            switch self {
            case .low: return "96 kbps"
            case .medium: return "192 kbps"
            case .high: return "320 kbps"
            }
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            List {
                // Playback section
                Section("Playback") {
                    HStack {
                        Text("Shuffle")
                        Spacer()
                        Toggle("", isOn: $audioPlayer.shuffleEnabled)
                            .tint(AppColors.lime)
                    }
                    
                    Picker("Repeat", selection: Binding(
                        get: { audioPlayer.repeatMode },
                        set: { audioPlayer.repeatMode = $0 }
                    )) {
                        Text("Off").tag(RepeatMode.off)
                        Text("One").tag(RepeatMode.one)
                        Text("All").tag(RepeatMode.all)
                    }
                    .pickerStyle(.menu)
                    
                    Button(action: { showingSleepTimer = true }) {
                        HStack {
                            Text("Sleep Timer")
                            Spacer()
                            Text(sleepTimerDuration > 0 ? "\(Int(sleepTimerDuration)) min" : "Off")
                                .foregroundColor(AppColors.grayLight)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.grayMedium)
                        }
                    }
                }
                
                // Audio section
                Section("Audio") {
                    Picker("Audio Quality", selection: $audioQuality) {
                        ForEach(AudioQuality.allCases, id: \.self) { quality in
                            Text("\(quality.rawValue) - \(quality.description)")
                                .tag(quality)
                        }
                    }
                    
                    Toggle("Show Lyrics When Available", isOn: $showLyrics)
                        .tint(AppColors.lime)
                    
                    Toggle("Allow Cellular Data", isOn: $useCellularData)
                        .tint(AppColors.lime)
                }
                
                // Library section
                Section("Library") {
                    HStack {
                        Text("Songs")
                        Spacer()
                        Text("\(library.songs.count)")
                            .foregroundColor(AppColors.grayLight)
                    }
                    
                    HStack {
                        Text("Playlists")
                        Spacer()
                        Text("\(library.playlists.count)")
                            .foregroundColor(AppColors.grayLight)
                    }
                    
                    Button(action: clearCache) {
                        HStack {
                            Text("Clear Artwork Cache")
                            Spacer()
                            Image(systemName: "trash")
                                .foregroundColor(AppColors.error)
                        }
                    }
                }
                
                // About section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppColors.grayLight)
                    }
                    
                    Text("MminoPlayer is an offline-first music player built with Swift and SwiftUI.")
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.grayMedium)
                        .padding(.top, AppTheme.spacingSM)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .tint(AppColors.lime)
        .navigationTitle("Settings")
        .sheet(isPresented: $showingSleepTimer) {
            SleepTimerSheet(
                duration: $sleepTimerDuration,
                onDismiss: {
                    // TODO: Implement actual sleep timer functionality
                }
            )
        }
        .onAppear {
        }
    }
    
    private func clearCache() {
        ArtworkManager.shared.clearCache()
        ArtworkCacheManager.shared.clearCache()
    }
}

struct SleepTimerSheet: View {
    @Binding var duration: Double
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    let durations: [Double] = [5, 10, 15, 30, 45, 60, 90, 120]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: AppTheme.spacingMD) {
                    ForEach(durations, id: \.self) { minutes in
                        Button(action: {
                            duration = minutes
                            dismiss()
                        }) {
                            Text("\(Int(minutes)) minutes")
                                .font(AppTypography.bodyLarge)
                                .foregroundColor(AppColors.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppTheme.spacingMD)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMD)
                                        .fill(duration == minutes ? AppColors.lime : AppColors.surfaceElevated)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Button(action: {
                        duration = 0
                        dismiss()
                    }) {
                        Text("Turn Off")
                            .font(AppTypography.bodyLarge)
                            .foregroundColor(AppColors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingMD)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, AppTheme.spacingLG)
                }
                .padding()
            }
            .navigationTitle("Sleep Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.lime)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(audioPlayer: AudioPlayer.shared)
    }
}
