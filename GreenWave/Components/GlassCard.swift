//
//  GlassCard.swift
//  GreenWave
//
//  Reusable glassmorphism card component
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var paddingAmount: CGFloat = AppTheme.Spacing.lg
    var cornerRadius: CGFloat = AppTheme.CornerRadius.xl
    var opacity: Double = 1.0
    var borderOpacity: Double = 0.12
    var backgroundOpacity: Double = 0.08
    
    init(
        paddingAmount: CGFloat = AppTheme.Spacing.lg,
        cornerRadius: CGFloat = AppTheme.CornerRadius.xl,
        opacity: Double = 1.0,
        borderOpacity: Double = 0.12,
        backgroundOpacity: Double = 0.08,
        @ViewBuilder content: () -> Content
    ) {
        self.paddingAmount = paddingAmount
        self.cornerRadius = cornerRadius
        self.opacity = opacity
        self.borderOpacity = borderOpacity
        self.backgroundOpacity = backgroundOpacity
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(paddingAmount)
            .background(.ultraThinMaterial)
            .background(AppColors.glassBackground.opacity(backgroundOpacity))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.white.opacity(borderOpacity), lineWidth: 1)
            }
            .opacity(opacity)
    }
}

// MARK: - Interactive Glass Card

struct InteractiveGlassCard<Content: View>: View {
    let content: Content
    var action: () -> Void
    
    @State private var isPressed = false
    
    init(
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: action) {
            GlassCard {
                content
            }
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in 
                    isPressed = false
                    action()
                }
        )
    }
}

// MARK: - Glass Container

struct GlassContainer<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = AppTheme.CornerRadius.xxl
    
    init(
        cornerRadius: CGFloat = AppTheme.CornerRadius.xxl,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .background(.ultraThinMaterial)
            .background(AppColors.surface.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.white.opacity(0.08), lineWidth: 1)
            }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack(spacing: AppTheme.Spacing.lg) {
            GlassCard {
                Text("Regular Glass Card")
                    .foregroundColor(AppColors.textPrimary)
            }
            
            InteractiveGlassCard(action: {
                print("Tapped!")
            }) {
                Text("Interactive Glass Card")
                    .foregroundColor(AppColors.textPrimary)
            }
            
            GlassContainer {
                Text("Glass Container")
                    .foregroundColor(AppColors.textPrimary)
                    .padding()
            }
        }
        .padding()
    }
}
