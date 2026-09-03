//
//  AppTypography.swift
//  GreenWave
//
//  Typography styles for the GreenWave music player
//

import SwiftUI

struct AppTypography {
    // MARK: - Display
    
    static let displayLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    
    // MARK: - Headline
    
    static let headlineLarge = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let headlineSmall = Font.system(size: 17, weight: .semibold, design: .rounded)
    
    // MARK: - Title
    
    static let titleLarge = Font.system(size: 22, weight: .medium, design: .rounded)
    static let titleMedium = Font.system(size: 17, weight: .medium, design: .rounded)
    static let titleSmall = Font.system(size: 14, weight: .medium, design: .rounded)
    
    // MARK: - Body
    
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .rounded)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .rounded)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .rounded)
    
    // MARK: - Caption
    
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .rounded)
    
    // MARK: - Button
    
    static let buttonLarge = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let buttonMedium = Font.system(size: 15, weight: .semibold, design: .rounded)
    static let buttonSmall = Font.system(size: 13, weight: .semibold, design: .rounded)
}

// MARK: - View Extensions

extension View {
    func headlineLarge() -> some View {
        self.font(AppTypography.headlineLarge)
    }
    
    func headlineMedium() -> some View {
        self.font(AppTypography.headlineMedium)
    }
    
    func titleLarge() -> some View {
        self.font(AppTypography.titleLarge)
    }
    
    func titleMedium() -> some View {
        self.font(AppTypography.titleMedium)
    }
    
    func bodyMedium() -> some View {
        self.font(AppTypography.bodyMedium)
    }
    
    func caption() -> some View {
        self.font(AppTypography.caption)
    }
}
