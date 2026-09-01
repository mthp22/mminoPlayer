//
//  SettingsView.swift
//  GreenWave
//
//  App settings and preferences
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("sleepTimerDuration") private var sleepTimerDuration = 0
    @AppStorage("showLyrics") private var showLyrics = false
    @AppStorage("crossfadeEnabled") private var crossfadeEnabled = false
    @AppStorage("crossfadeDuration") private var crossfadeDuration = 5.0
    @AppStorage("normalizeAudio") private var normalizeAudio = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                List {
                    // Playback Section
                    Section(header: settingsSectionHeader(title: "Playback")) {
                        Toggle("Shuffle by Default", isOn: .constant(AudioPlayer.shared.shuffleEnabled))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Picker("Repeat Mode", selection: Binding(
                            get: { AudioPlayer.shared.repeatMode },
                            set: { AudioPlayer.shared.repeatMode = $0 }
                        )) {
                            Text("Off").tag(RepeatMode.off)
                            Text("One").tag(RepeatMode.one)
                            Text("All").tag(RepeatMode.all)
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(AppColors.textPrimary)
                        
                        Toggle("Crossfade", isOn: $crossfadeEnabled)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if crossfadeEnabled {
                            HStack {
                                Text("Crossfade Duration")
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Text("\(Int(crossfadeDuration))s")
                                    .foregroundColor(AppColors.textTertiary)
                            }
                            
                            Slider(value: $crossfadeDuration, in: 1...15, step: 1)
                                .tint(AppColors.primaryAction)
                        }
                        
                        Toggle("Normalize Audio", isOn: $normalizeAudio)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Sleep Timer Section
                    Section(header: settingsSectionHeader(title: "Sleep Timer")) {
                        Picker("Duration", selection: $sleepTimerDuration) {
                            Text("Off").tag(0)
                            Text("15 min").tag(15)
                            Text("30 min").tag(30)
                            Text("45 min").tag(45)
                            Text("1 hour").tag(60)
                        }
                        .pickerStyle(.menu)
                        .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Display Section
                    Section(header: settingsSectionHeader(title: "Display")) {
                        Toggle("Show Lyrics", isOn: $showLyrics)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    // Storage Section
                    Section(header: settingsSectionHeader(title: "Storage")) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Library Size")
                                    .font(AppTypography.bodyMedium)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("\(MusicLibrary.shared.songs.count) songs")
                                    .font(AppTypography.captionSmall)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            Spacer()
                            
                            Button("Clear Cache") {
                                ArtworkManager.shared.clearCache()
                            }
                            .foregroundColor(AppColors.primaryAction)
                        }
                    }
                    
                    // About Section
                    Section(header: settingsSectionHeader(title: "About")) {
                        HStack {
                            Text("Version")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(AppColors.textTertiary)
                        }
                        
                        Link(destination: URL(string: "https://greenwave.app")!) {
                            HStack {
                                Text("Website")
                                    .foregroundColor(AppColors.textSecondary)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                        
                        HStack {
                            Text("Built with")
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.primaryAction)
                                Text("in California")
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
        }
    }
    
    private func settingsSectionHeader(title: String) -> some View {
        Text(title)
            .font(AppTypography.titleSmall)
            .foregroundColor(AppColors.primaryAction)
            .textCase(.uppercase)
    }
}

#Preview {
    SettingsView()
        .environmentObject(MusicLibrary.shared)
        .environmentObject(AudioPlayer.shared)
}
