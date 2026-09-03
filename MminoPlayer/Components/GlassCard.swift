//
//  GlassCard.swift
//  MminoPlayer
//
//  Reusable glassmorphism card component

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
        @ViewBuilder content: () -> Content,
        padding: CGFloat = AppTheme.spacingMD,
        cornerRadius: CGFloat = AppTheme.cornerRadiusXL,
        backgroundOpacity: Double = 0.08,
        borderOpacity: Double = 0.12,
        shadowColor: Color = .clear,
        shadowRadius: CGFloat = 0
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
            .background(AppColors.glassBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(AppColors.glassBorder.opacity(borderOpacity), lineWidth: 1)
            }
            .shadow(color: shadowColor, radius: shadowRadius)
    }
}

// MARK: - Variants

struct GlassButton: View {
    let icon: String
    let action: () -> Void
    let size: CGFloat
    let isActive: Bool
    
    init(
        icon: String,
        action: @escaping () -> Void,
        size: CGFloat = AppTheme.buttonSizeMD,
        isActive: Bool = false
    ) {
        self.icon = icon
        self.action = action
        self.size = size
        self.isActive = isActive
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .fontWeight(.semibold)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(isActive ? AppColors.lime : AppColors.glassBackground)
                        .opacity(isActive ? 1.0 : 0.3)
                )
                .foregroundColor(isActive ? AppColors.background : AppColors.white)
                .overlay(
                    Circle()
                        .stroke(AppColors.glassBorder.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GlassSlider<Label: View>: View {
    let value: Binding<Double>
    let range: ClosedRange<Double>
    let label: Label
    let onEditingChanged: (Bool) -> Void
    
    init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        @ViewBuilder label: () -> Label = { EmptyView() },
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.value = value
        self.range = range
        self.label = label()
        self.onEditingChanged = onEditingChanged
    }
    
    var body: some View {
        VStack(spacing: AppTheme.spacingXS) {
            label
            Slider(value: value, in: range, onEditingChanged: onEditingChanged)
                .tint(AppColors.lime)
        }
    }
}

extension GlassSlider where Label == EmptyView {
    init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        onEditingChanged: @escaping (Bool) -> Void = { _ in }
    ) {
        self.value = value
        self.range = range
        self.label = EmptyView()
        self.onEditingChanged = onEditingChanged
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        VStack(spacing: AppTheme.spacingLG) {
            GlassCard {
                Text("Glass Card Content")
                    .foregroundColor(AppColors.white)
            }
            
            HStack(spacing: AppTheme.spacingMD) {
                GlassButton(icon: "play.fill", action: {})
                GlassButton(icon: "pause.fill", action: {}, isActive: true)
                GlassButton(icon: "forward.fill", action: {})
            }
        }
        .padding()
    }
}
