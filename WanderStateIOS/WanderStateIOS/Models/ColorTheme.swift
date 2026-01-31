//
//  ColorTheme.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

// MARK: - Color Theme Definition

enum ColorTheme: String, CaseIterable, Identifiable {
    case vintageGreen = "vintage_green"
    case oceanBlue = "ocean_blue"
    case sunsetOrange = "sunset_orange"
    case rosewoodPink = "rosewood_pink"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .vintageGreen: return "Vintage Green"
        case .oceanBlue: return "Ocean Blue"
        case .sunsetOrange: return "Sunset Orange"
        case .rosewoodPink: return "Rosewood Pink"
        }
    }

    var description: String {
        switch self {
        case .vintageGreen: return "Classic explorer vibes"
        case .oceanBlue: return "Calm coastal colors"
        case .sunsetOrange: return "Warm adventure tones"
        case .rosewoodPink: return "Elegant travel style"
        }
    }

    // MARK: - Theme Colors

    var primary: Color {
        switch self {
        case .vintageGreen: return Color(hex: "2E7D32")  // Forest green
        case .oceanBlue: return Color(hex: "1565C0")     // Deep blue
        case .sunsetOrange: return Color(hex: "E65100")  // Burnt orange
        case .rosewoodPink: return Color(hex: "AD1457")  // Deep rose
        }
    }

    var primaryLight: Color {
        switch self {
        case .vintageGreen: return Color(hex: "4CAF50")  // Light green
        case .oceanBlue: return Color(hex: "42A5F5")     // Light blue
        case .sunsetOrange: return Color(hex: "FF9800")  // Orange
        case .rosewoodPink: return Color(hex: "EC407A")  // Pink
        }
    }

    var primaryDark: Color {
        switch self {
        case .vintageGreen: return Color(hex: "1B5E20")  // Dark green
        case .oceanBlue: return Color(hex: "0D47A1")     // Dark blue
        case .sunsetOrange: return Color(hex: "BF360C")  // Dark orange
        case .rosewoodPink: return Color(hex: "880E4F")  // Dark rose
        }
    }

    var secondary: Color {
        switch self {
        case .vintageGreen: return Color(hex: "8D6E63")  // Brown
        case .oceanBlue: return Color(hex: "26A69A")     // Teal
        case .sunsetOrange: return Color(hex: "795548")  // Brown
        case .rosewoodPink: return Color(hex: "7B1FA2")  // Purple
        }
    }

    var accent: Color {
        switch self {
        case .vintageGreen: return Color(hex: "FFC107")  // Amber
        case .oceanBlue: return Color(hex: "00BCD4")     // Cyan
        case .sunsetOrange: return Color(hex: "FFEB3B")  // Yellow
        case .rosewoodPink: return Color(hex: "E91E63")  // Pink
        }
    }

    // Main screen background - subtle, warm tones
    var background: Color {
        switch self {
        case .vintageGreen: return Color(hex: "F5F1E8")  // Warm tan/beige
        case .oceanBlue: return Color(hex: "E8F4F8")     // Soft blue-gray
        case .sunsetOrange: return Color(hex: "FFF5E8")  // Light peach/cream
        case .rosewoodPink: return Color(hex: "FFF0F5")  // Very light pink (lavender blush)
        }
    }

    // Card/surface background - slightly lighter than background
    var cardBackground: Color {
        switch self {
        case .vintageGreen: return Color(hex: "FDFCF9")  // Off-white with warm tint
        case .oceanBlue: return Color(hex: "F5FAFC")     // Very light blue-white
        case .sunsetOrange: return Color(hex: "FFFCF8")  // Cream white
        case .rosewoodPink: return Color(hex: "FFFBFC")  // Almost white with pink tint
        }
    }

    // Tertiary background for nested elements
    var tertiaryBackground: Color {
        switch self {
        case .vintageGreen: return Color(hex: "EDE8DC")  // Slightly darker tan
        case .oceanBlue: return Color(hex: "DCE8EC")     // Muted blue-gray
        case .sunsetOrange: return Color(hex: "F5E8D8")  // Muted peach
        case .rosewoodPink: return Color(hex: "F5E8EC")  // Muted pink
        }
    }

    var backgroundDark: Color {
        switch self {
        case .vintageGreen: return Color(hex: "1A2E1A")  // Dark green
        case .oceanBlue: return Color(hex: "0A1929")     // Dark blue
        case .sunsetOrange: return Color(hex: "2C1810")  // Dark brown
        case .rosewoodPink: return Color(hex: "2A1520")  // Dark rose
        }
    }

    var surface: Color {
        switch self {
        case .vintageGreen: return Color(hex: "DCEDC8")  // Soft green
        case .oceanBlue: return Color(hex: "BBDEFB")     // Soft blue
        case .sunsetOrange: return Color(hex: "FFE0B2")  // Soft orange
        case .rosewoodPink: return Color(hex: "F8BBD9")  // Soft pink
        }
    }

    // MARK: - State Colors (for map)

    var stateUnvisited: Color {
        Color(hex: "CCCCCC")  // Gray for all themes
    }

    var stateVisitedLight: Color {
        primaryLight.opacity(0.7)
    }

    var stateVisitedMedium: Color {
        primary
    }

    var stateVisitedDark: Color {
        primaryDark
    }

    // MARK: - Swatch Colors for Preview

    var swatchColors: [Color] {
        [primary, primaryLight, secondary, accent]
    }
}

// MARK: - Theme Manager

@Observable
class ThemeManager {
    static let shared = ThemeManager()

    private let themeKey = "selectedTheme"

    var currentTheme: ColorTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
        }
    }

    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = ColorTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .vintageGreen
        }
    }

    // Convenience accessors
    var primary: Color { currentTheme.primary }
    var primaryLight: Color { currentTheme.primaryLight }
    var primaryDark: Color { currentTheme.primaryDark }
    var secondary: Color { currentTheme.secondary }
    var accent: Color { currentTheme.accent }
    var background: Color { currentTheme.background }
    var cardBackground: Color { currentTheme.cardBackground }
    var tertiaryBackground: Color { currentTheme.tertiaryBackground }
    var surface: Color { currentTheme.surface }
}

// MARK: - Environment Key

struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeManager = ThemeManager.shared
}

extension EnvironmentValues {
    var theme: ThemeManager {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - Navigation Manager

@Observable
class NavigationManager {
    static let shared = NavigationManager()

    var selectedTab: Int = 0
    var galleryStateFilter: String? = nil

    private init() {}

    func navigateToGallery(forState stateName: String) {
        galleryStateFilter = stateName
        selectedTab = 1  // Gallery tab
    }

    func clearGalleryFilter() {
        galleryStateFilter = nil
    }
}
