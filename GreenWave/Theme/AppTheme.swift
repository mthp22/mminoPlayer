//
//  AppTheme.swift
//  GreenWave
//
//  Theme configuration for the GreenWave music player
//

import SwiftUI

struct AppTheme {
    // MARK: - Spacing
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let huge: CGFloat = 32
    }
    
    // MARK: - Corner Radius
    
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let huge: CGFloat = 32
        static let circular: CGFloat = 999
    }
    
    // MARK: - Icon Sizes
    
    enum IconSize {
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
        static let huge: CGFloat = 48
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0.3)
    }
    
    // MARK: - Shadow
    
    enum Shadow {
        static let small = CGSize(width: 0, height: 2)
        static let medium = CGSize(width: 0, height: 4)
        static let large = CGSize(width: 0, height: 8)
        
        static func glow(color: Color = AppColors.green, radius: CGFloat = 20) -> some View {
            AnyView(
                Color.clear
                    .shadow(color: color.opacity(0.3), radius: radius)
            )
        }
    }
    
    // MARK: - Blur
    
    enum Blur {
        static let material: Material = .ultraThinMaterial
        static let regular: Material = .thinMaterial
        static let heavy: Material = .material
    }
}

// MARK: - Environment Values

private struct GlassEffectKey: EnvironmentKey {
    static var defaultValue: Bool = true
}

extension EnvironmentValues {
    var glassEffectEnabled: Bool {
        get { self[GlassEffectKey.self] }
        set { self[GlassEffectKey.self] = newValue }
    }
}

extension View {
    func glassEffect(enabled: Bool = true) -> some View {
        self.environment(\.glassEffectEnabled, enabled)
    }
}
