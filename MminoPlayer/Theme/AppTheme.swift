//
//  AppTheme.swift
//  MminoPlayer
//
//  Centralized theme configuration

import SwiftUI

struct AppTheme {
    // Spacing scale
    static let spacingXXS: CGFloat = 4
    static let spacingXS: CGFloat = 8
    static let spacingSM: CGFloat = 12
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32
    static let spacingXXL: CGFloat = 48
    
    // Corner radii
    static let cornerRadiusSM: CGFloat = 8
    static let cornerRadiusMD: CGFloat = 12
    static let cornerRadiusLG: CGFloat = 16
    static let cornerRadiusXL: CGFloat = 24
    static let cornerRadiusXXL: CGFloat = 32
    
    // Shadow configuration
    static let shadowColor = Color.black.opacity(0.3)
    static let shadowRadius: CGFloat = 8
    static let shadowOffset = CGSize(width: 0, height: 4)
    
    // Glow effect for green accent
    static func greenGlow(intensity: CGFloat = 0.5) -> Shadow {
        Shadow(color: AppColors.green.opacity(intensity), radius: 20 * intensity)
    }
    
    // Animation presets
    static let animationFast = Animation.easeOut(duration: 0.2)
    static let animationDefault = Animation.easeOut(duration: 0.3)
    static let animationSlow = Animation.easeOut(duration: 0.5)
    static let animationSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    
    // Progress bar height
    static let progressHeight: CGFloat = 4
    static let progressActiveHeight: CGFloat = 6
    
    // Button sizes
    static let buttonSizeSM: CGFloat = 32
    static let buttonSizeMD: CGFloat = 44
    static let buttonSizeLG: CGFloat = 56
    static let buttonSizeXL: CGFloat = 72
    
    // Artwork sizes
    static let artworkSizeMini: CGFloat = 40
    static let artworkSizeSmall: CGFloat = 60
    static let artworkSizeMedium: CGFloat = 120
    static let artworkSizeLarge: CGFloat = 200
    static let artworkSizeXLarge: CGFloat = 280
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let offset: CGSize
    
    init(color: Color, radius: CGFloat, offset: CGSize = .zero) {
        self.color = color
        self.radius = radius
        self.offset = offset
    }
}
