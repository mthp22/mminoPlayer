//
//  SourcesView.swift
//  MminoPlayer
//
//  Where music comes from: importing files from the Files app, plus
//  placeholders for sources that are not built yet. Import lives here (not
//  in the Library toolbar) so uploads have one obvious home.
//

import SwiftUI

struct SourcesView: View {
    @StateObject private var library = MusicLibrary.shared

    @State private var showingImporter = false
    @State private var importMessage: String?
    @State private var isImporting = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.spacingLG) {
                    VStack(alignment: .leading, spacing: AppTheme.spacingXS) {
                        Text("Where your music lives")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.grayLight)

                        Text("Your Sources")
                            .font(AppTypography.displayLarge)
                            .foregroundColor(AppColors.white)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityElement(children: .combine)

                    sectionTitle("Import")
                    filesCard

                    sectionTitle("Coming Soon")
                    comingSoonCard(
                        icon: "arrow.down.circle",
                        title: "MP3 Downloader",
                        subtitle: "Search and download tracks directly",
                        color: AppColors.green
                    )
                    comingSoonCard(
                        icon: "cloud",
                        title: "Google Drive",
                        subtitle: "Stream or import from your Drive",
                        color: AppColors.greenLight
                    )

                    Spacer(minLength: 100)
                }
                .padding(.horizontal, AppTheme.spacingMD)
                .padding(.top, AppTheme.spacingSM)
            }
        }
        .navigationTitle("Sources")
        .navigationBarTitleDisplayMode(.large)
        .overlay {
            if isImporting {
                importProgressOverlay
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: FileImporter.shared.supportedTypes,
            allowsMultipleSelection: true
        ) { result in
            handleFileImport(result: result)
        }
        .alert("Import", isPresented: importMessageBinding) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importMessage ?? "")
        }
    }

    // MARK: - Sections

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(AppTypography.headlineMedium)
            .foregroundColor(AppColors.white)
            .padding(.top, AppTheme.spacingSM)
    }

    private var filesCard: some View {
        Button(action: { showingImporter = true }) {
            GlassCard(padding: AppTheme.spacingMD, cornerRadius: AppTheme.cornerRadiusLG) {
                HStack(spacing: AppTheme.spacingMD) {
                    ZStack {
                        Circle()
                            .fill(AppColors.lime.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 22))
                            .foregroundColor(AppColors.lime)
                    }

                    VStack(alignment: .leading, spacing: AppTheme.spacingXXS) {
                        Text("Files")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.white)

                        Text("Import audio files from the Files app")
                            .font(AppTypography.caption)
                            .foregroundColor(AppColors.grayLight)
                    }

                    Spacer(minLength: AppTheme.spacingXS)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.grayMedium)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isImporting)
        .accessibilityLabel("Import music")
        .accessibilityHint("Imports audio files from the Files app")
    }

    private func comingSoonCard(icon: String, title: String, subtitle: String, color: Color) -> some View {
        GlassCard(padding: AppTheme.spacingMD, cornerRadius: AppTheme.cornerRadiusLG) {
            HStack(spacing: AppTheme.spacingMD) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.12))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                .opacity(0.5)

                VStack(alignment: .leading, spacing: AppTheme.spacingXXS) {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.grayMedium)

                    Text(subtitle)
                        .font(AppTypography.caption)
                        .foregroundColor(AppColors.grayDark)
                }

                Spacer(minLength: AppTheme.spacingXS)

                Text("COMING SOON")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppColors.lime)
                    .padding(.horizontal, AppTheme.spacingSM)
                    .padding(.vertical, AppTheme.spacingXXS)
                    .overlay(
                        Capsule()
                            .stroke(AppColors.lime.opacity(0.6), lineWidth: 1)
                    )
            }
        }
        .accessibilityHint("Not available yet")
    }

    // MARK: - Import progress

    private var importProgressOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: AppTheme.spacingSM) {
                ProgressView()
                    .tint(AppColors.lime)
                Text("Importing…")
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.white)
            }
            .padding(AppTheme.spacingLG)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLG))
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: - File import

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importMessage = error.localizedDescription

        case .success(let urls):
            guard !urls.isEmpty else { return }
            isImporting = true

            Task {
                let musicDir = FileImporter.shared.ensureMusicDirectory()
                var imported = 0
                var duplicates = 0
                var failures: [String] = []

                for url in urls {
                    do {
                        if let song = try await FileImporter.shared.importFile(from: url, to: musicDir) {
                            if library.addSong(song) {
                                imported += 1
                            } else {
                                // Same content already in the library: drop
                                // the redundant copy.
                                FileImporter.shared.deleteSongFile(song)
                                duplicates += 1
                            }
                        } else {
                            duplicates += 1
                        }
                    } catch {
                        failures.append("\(url.lastPathComponent): \(error.localizedDescription)")
                    }
                }

                isImporting = false
                importMessage = Self.importSummary(
                    imported: imported,
                    duplicates: duplicates,
                    failures: failures
                )
            }
        }
    }

    private static func importSummary(imported: Int, duplicates: Int, failures: [String]) -> String {
        var parts: [String] = []
        if imported > 0 {
            parts.append("Imported \(imported) song\(imported == 1 ? "" : "s").")
        }
        if duplicates > 0 {
            parts.append("\(duplicates) file\(duplicates == 1 ? " was" : "s were") already in your library.")
        }
        if !failures.isEmpty {
            parts.append("Failed to import \(failures.count) file\(failures.count == 1 ? "" : "s"):")
            parts.append(contentsOf: failures.prefix(3))
        }
        if parts.isEmpty {
            return "Nothing was imported."
        }
        return parts.joined(separator: "\n")
    }

    private var importMessageBinding: Binding<Bool> {
        Binding(
            get: { importMessage != nil },
            set: { newValue in
                if !newValue {
                    importMessage = nil
                }
            }
        )
    }
}

#Preview {
    NavigationStack {
        SourcesView()
    }
}
