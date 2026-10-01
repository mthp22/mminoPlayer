//
//  EmptyStateView.swift
//  MminoPlayer
//
//  Beautiful empty state component

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "music.note",
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacingLG) {
            // Icon with glow effect
            ZStack {
                Circle()
                    .fill(AppColors.green.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: icon)
                    .font(.system(size: 36))
                    .foregroundColor(AppColors.lime)
            }
            
            Text(title)
                .font(AppTypography.headlineLarge)
                .foregroundColor(AppColors.white)
            
            Text(message)
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.grayLight)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(AppColors.background)
                        .padding(.horizontal, AppTheme.spacingLG)
                        .padding(.vertical, AppTheme.spacingSM)
                        .background(AppColors.lime)
                        .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, AppTheme.spacingSM)
            }
        }
        .padding(AppTheme.spacingXL)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "music.note",
        title: "Your library is empty",
        message: "Import music from Files\nto start building your\noffline library.",
        actionTitle: "Add Music",
        action: {}
    )
    .background(AppColors.background)
}
