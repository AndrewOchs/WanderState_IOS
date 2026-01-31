//
//  ColorTheme.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light = "light"
    case dark = "dark"
    case system = "system"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }
}

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

    // MARK: - Light Mode Backgrounds

    var backgroundLight: Color {
        switch self {
        case .vintageGreen: return Color(hex: "F5F1E8")  // Warm tan/beige
        case .oceanBlue: return Color(hex: "E8F4F8")     // Soft blue-gray
        case .sunsetOrange: return Color(hex: "FFF5E8")  // Light peach/cream
        case .rosewoodPink: return Color(hex: "FFF0F5")  // Very light pink
        }
    }

    var cardBackgroundLight: Color {
        switch self {
        case .vintageGreen: return Color(hex: "FDFCF9")  // Off-white with warm tint
        case .oceanBlue: return Color(hex: "F5FAFC")     // Very light blue-white
        case .sunsetOrange: return Color(hex: "FFFCF8")  // Cream white
        case .rosewoodPink: return Color(hex: "FFFBFC")  // Almost white with pink tint
        }
    }

    var tertiaryBackgroundLight: Color {
        switch self {
        case .vintageGreen: return Color(hex: "EDE8DC")  // Slightly darker tan
        case .oceanBlue: return Color(hex: "DCE8EC")     // Muted blue-gray
        case .sunsetOrange: return Color(hex: "F5E8D8")  // Muted peach
        case .rosewoodPink: return Color(hex: "F5E8EC")  // Muted pink
        }
    }

    // MARK: - Dark Mode Backgrounds

    var backgroundDark: Color {
        switch self {
        case .vintageGreen: return Color(hex: "121A12")  // Very dark green-tinted
        case .oceanBlue: return Color(hex: "0D1520")     // Very dark blue-tinted
        case .sunsetOrange: return Color(hex: "1A1210")  // Very dark warm
        case .rosewoodPink: return Color(hex: "1A1218")  // Very dark pink-tinted
        }
    }

    var cardBackgroundDark: Color {
        switch self {
        case .vintageGreen: return Color(hex: "1E2A1E")  // Dark green card
        case .oceanBlue: return Color(hex: "162030")     // Dark blue card
        case .sunsetOrange: return Color(hex: "2A1E18")  // Dark orange card
        case .rosewoodPink: return Color(hex: "2A1A22")  // Dark pink card
        }
    }

    var tertiaryBackgroundDark: Color {
        switch self {
        case .vintageGreen: return Color(hex: "283828")  // Tertiary dark green
        case .oceanBlue: return Color(hex: "1E2A3A")     // Tertiary dark blue
        case .sunsetOrange: return Color(hex: "3A2820")  // Tertiary dark orange
        case .rosewoodPink: return Color(hex: "3A222C")  // Tertiary dark pink
        }
    }

    // MARK: - Dynamic Colors (used by ThemeManager based on appearance)

    var background: Color { backgroundLight }
    var cardBackground: Color { cardBackgroundLight }
    var tertiaryBackground: Color { tertiaryBackgroundLight }

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
    private let appearanceKey = "appearanceMode"

    var currentTheme: ColorTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
        }
    }

    var appearanceMode: AppearanceMode {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: appearanceKey)
        }
    }

    // Track system color scheme for dynamic updates
    var systemColorScheme: ColorScheme = .light

    private init() {
        // Load saved theme
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = ColorTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .vintageGreen
        }

        // Load saved appearance mode
        if let savedMode = UserDefaults.standard.string(forKey: appearanceKey),
           let mode = AppearanceMode(rawValue: savedMode) {
            self.appearanceMode = mode
        } else {
            self.appearanceMode = .light
        }
    }

    // Computed property to determine if we're in dark mode
    var isDarkMode: Bool {
        switch appearanceMode {
        case .light:
            return false
        case .dark:
            return true
        case .system:
            return systemColorScheme == .dark
        }
    }

    // Convenience accessors - these stay the same (don't change with mode)
    var primary: Color { currentTheme.primary }
    var primaryLight: Color { currentTheme.primaryLight }
    var primaryDark: Color { currentTheme.primaryDark }
    var secondary: Color { currentTheme.secondary }
    var accent: Color { currentTheme.accent }
    var surface: Color { currentTheme.surface }

    // Dynamic background colors based on appearance mode
    var background: Color {
        isDarkMode ? currentTheme.backgroundDark : currentTheme.backgroundLight
    }

    var cardBackground: Color {
        isDarkMode ? currentTheme.cardBackgroundDark : currentTheme.cardBackgroundLight
    }

    var tertiaryBackground: Color {
        isDarkMode ? currentTheme.tertiaryBackgroundDark : currentTheme.tertiaryBackgroundLight
    }

    // Preferred color scheme for SwiftUI
    var preferredColorScheme: ColorScheme? {
        appearanceMode.colorScheme
    }
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
