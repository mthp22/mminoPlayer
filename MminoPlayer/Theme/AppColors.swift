//
//  AppColors.swift
//  MminoPlayer
//
//  Color palette for the dark green theme with lime accents

import SwiftUI

struct AppColors {
    // Background colors
    static let background = Color(hex: "071A13")
    static let surface = Color(hex: "0D281E")
    static let surfaceElevated = Color(hex: "153629")
    
    // Primary colors
    static let green = Color(hex: "18A86B")
    static let greenLight = Color(hex: "2EC48A")
    static let greenDark = Color(hex: "0F7A4D")
    
    // Accent color - lime/yellow for active states
    static let lime = Color(hex: "D9F63C")
    static let limeLight = Color(hex: "E8FC5C")
    static let limeDark = Color(hex: "B8D432")
    
    // Neutral colors
    static let white = Color(hex: "FFFFFF")
    static let grayLight = Color(hex: "A0B4AC")
    static let grayMedium = Color(hex: "5C7568")
    static let grayDark = Color(hex: "2A3D35")
    
    // Glass effects
    static let glassBackground = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    static let glassHighlight = Color.white.opacity(0.2)
    
    // Functional colors
    static let error = Color(hex: "FF6B6B")
    static let success = green
    static let warning = Color(hex: "FFB84D")
}

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
            (a, r, g, b) = (255, 0, 0, 0)
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
