//
//  AppColors.swift
//  GreenWave
//
//  Color palette for the GreenWave music player
//

import SwiftUI

struct AppColors {
    // MARK: - Primary Colors
    
    static let background = Color(hex: "071A13")
    static let surface = Color(hex: "0D281E")
    static let green = Color(hex: "18A86B")
    static let lime = Color(hex: "D9F63C")
    static let white = Color(hex: "FFFFFF")
    
    // MARK: - Semantic Colors
    
    static let primaryAction = lime
    static let secondaryAction = green
    static let accent = green
    
    // MARK: - Utility Colors
    
    static let glassBackground = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.5)
    static let divider = Color.white.opacity(0.1)
    
    // MARK: - Gradients
    
    static let primaryGradient = LinearGradient(
        colors: [green, lime],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [background, surface],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let glowGradient = RadialGradient(
        colors: [green.opacity(0.3), .clear],
        center: .center,
        startRadius: 0,
        endRadius: 200
    )
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
