//
//  GreenWaveApp.swift
//  GreenWave
//
//  Main entry point for the GreenWave music player
//

import SwiftUI
import SwiftData

@main
struct GreenWaveApp: App {
    @StateObject private var audioPlayer = AudioPlayer.shared
    @StateObject private var musicLibrary = MusicLibrary.shared
    @StateObject private var audioSessionManager = AudioSessionManager.shared
    
    @State private var showFullPlayer = false
    @State private var selectedTab = 0
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioPlayer)
                .environmentObject(musicLibrary)
                .environmentObject(audioSessionManager)
                .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Content View

struct ContentView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    @EnvironmentObject var musicLibrary: MusicLibrary
    @State private var selectedTab = 0
    @State private var showFullPlayer = false
    @State private var showingImportSheet = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                LibraryView(showingImportSheet: $showingImportSheet)
                    .tabItem {
                        Label("Library", systemImage: "house.fill")
                    }
                    .tag(0)
                
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .tag(1)
                
                PlaylistsView()
                    .tabItem {
                        Label("Playlists", systemImage: "list.bullet.rectangle")
                    }
                    .tag(2)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(3)
            }
            .tint(AppColors.primaryAction)
            
            // Mini Player
            VStack {
                Spacer()
                
                MiniPlayerWithProgress(onTap: {
                    showFullPlayer = true
                })
            }
            .padding(.bottom, 80)
            .padding(.horizontal)
        }
        .sheet(isPresented: $showFullPlayer) {
            PlayerView()
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled)
        }
        .sheet(isPresented: $showingImportSheet) {
            FileImporterView()
        }
        .onAppear {
            musicLibrary.loadLibrary()
            audioSessionManager.setupAudioSession()
        }
    }
}

// MARK: - File Importer View

struct FileImporterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var musicLibrary: MusicLibrary
    @State private var isImporting = false
    @State private importStatus = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: AppTheme.Spacing.xl) {
                    Image(systemName: "arrow.down.doc.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primaryAction)
                    
                    Text("Import Music")
                        .font(AppTypography.headlineLarge)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("Select audio files from your device to add them to your library.")
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppTheme.Spacing.xxl)
                    
                    if isImporting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryAction))
                        
                        Text(importStatus)
                            .font(AppTypography.captionSmall)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Import Music")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.textPrimary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Select Files") {
                        Task {
                            await importFiles()
                        }
                    }
                    .foregroundColor(AppColors.primaryAction)
                }
            }
        }
    }
    
    private func importFiles() async {
        isImporting = true
        importStatus = "Waiting for file selection..."
        
        // In a real implementation, this would use UIDocumentPickerViewController
        // For now, we'll simulate the import process
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        isImporting = false
        dismiss()
    }
}

#Preview {
    GreenWaveApp()
}
