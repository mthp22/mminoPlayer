//
//  AppTypography.swift
//  MminoPlayer
//
//  Typography scale for consistent text styling

import SwiftUI

struct AppTypography {
    // Display styles
    static let displayLarge = Font.system(size: 32, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let displaySmall = Font.system(size: 24, weight: .semibold, design: .rounded)
    
    // Headline styles
    static let headlineLarge = Font.system(size: 22, weight: .semibold, design: .default)
    static let headlineMedium = Font.system(size: 18, weight: .medium, design: .default)
    static let headlineSmall = Font.system(size: 16, weight: .medium, design: .default)
    
    // Body styles
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)
    
    // Caption styles
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)
    
    // Button styles
    static let buttonLarge = Font.system(size: 17, weight: .semibold, design: .default)
    static let buttonMedium = Font.system(size: 15, weight: .medium, design: .default)
}

extension View {
    func titleStyle() -> some View {
        self.font(AppTypography.displayMedium)
            .foregroundColor(AppColors.white)
    }
    
    func headingStyle() -> some View {
        self.font(AppTypography.headlineLarge)
            .foregroundColor(AppColors.white)
    }
    
    func subtitleStyle() -> some View {
        self.font(AppTypography.bodyLarge)
            .foregroundColor(AppColors.grayLight)
    }
    
    func songTitleStyle() -> some View {
        self.font(AppTypography.headlineMedium)
            .foregroundColor(AppColors.white)
    }
    
    func artistStyle() -> some View {
        self.font(AppTypography.bodyMedium)
            .foregroundColor(AppColors.grayLight)
    }
    
    func metadataStyle() -> some View {
        self.font(AppTypography.caption)
            .foregroundColor(AppColors.grayMedium)
    }
}
