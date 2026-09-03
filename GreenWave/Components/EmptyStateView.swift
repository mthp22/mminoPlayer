//
//  EmptyStateView.swift
//  GreenWave
//
//  Beautiful empty state component
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            // Icon with glow effect
            ZStack {
                AppColors.glowGradient
                
                Image(systemName: icon)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(AppColors.white.opacity(0.8))
            }
            .frame(width: 120, height: 120)
            
            // Title
            Text(title)
                .font(AppTypography.headlineMedium)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(4)
            
            // Action button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                        Text(actionTitle)
                            .font(AppTypography.buttonMedium)
                    }
                    .foregroundColor(AppColors.background)
                    .padding(.horizontal, AppTheme.Spacing.xl)
                    .padding(.vertical, AppTheme.Spacing.md)
                    .background(AppColors.primaryAction)
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, AppTheme.Spacing.lg)
            }
        }
        .padding(AppTheme.Spacing.xxl)
    }
}

// MARK: - Library Empty State

struct LibraryEmptyState: View {
    var onImportMusic: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "music.note.list",
            title: "Your library is empty",
            message: "Import music from Files to start building your offline library.",
            actionTitle: "Add Music",
            action: onImportMusic
        )
    }
}

// MARK: - Search Empty State

struct SearchEmptyState: View {
    var query: String
    
    var body: some View {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No results found",
            message: "We couldn't find anything matching \"\(query)\". Try a different search term."
        )
    }
}

// MARK: - Favorites Empty State

struct FavoritesEmptyState: View {
    var body: some View {
        EmptyStateView(
            icon: "heart",
            title: "No favorites yet",
            message: "Songs you mark as favorites will appear here for quick access."
        )
    }
}

// MARK: - Playlists Empty State

struct PlaylistsEmptyState: View {
    var onCreatePlaylist: () -> Void
    
    var body: some View {
        EmptyStateView(
            icon: "list.bullet.rectangle",
            title: "No playlists",
            message: "Create your first playlist to organize your music.",
            actionTitle: "Create Playlist",
            action: onCreatePlaylist
        )
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack(spacing: 40) {
            LibraryEmptyState(onImportMusic: {})
            
            Divider()
            
            SearchEmptyState(query: "test")
            
            Divider()
            
            FavoritesEmptyState()
        }
    }
}
