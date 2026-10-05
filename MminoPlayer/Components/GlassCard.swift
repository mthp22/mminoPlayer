//
//  GlassCard.swift
//  MminoPlayer
//
//  Reusable glassmorphism card component used globally.

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let backgroundOpacity: Double
    let borderOpacity: Double
    let shadowColor: Color
    let shadowRadius: CGFloat

    init(
        padding: CGFloat = AppTheme.spacingMD,
        cornerRadius: CGFloat = AppTheme.cornerRadiusXL,
        backgroundOpacity: Double = 0.08,
        borderOpacity: Double = 0.12,
        shadowColor: Color = .clear,
        shadowRadius: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundOpacity = backgroundOpacity
        self.borderOpacity = borderOpacity
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.glassBorder.opacity(borderOpacity), lineWidth: 1)
            }
            .shadow(color: shadowColor, radius: shadowRadius)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()

        GlassCard {
            Text("Glass Card Content")
                .foregroundColor(AppColors.white)
        }
        .padding()
    }
}
