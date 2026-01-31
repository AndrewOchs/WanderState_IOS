//
//  SettingsScreen.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import SwiftData

struct SettingsScreen: View {
    @State private var themeManager = ThemeManager.shared
    @Query private var photos: [PhotoEntity]
    @Environment(\.modelContext) private var modelContext

    @State private var showClearDataAlert = false
    @State private var showExportSheet = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // MARK: - App Logo Header
                    appLogoHeader

                    // MARK: - Color Theme Section
                    themeSection

                    // MARK: - Data Management Section
                    dataManagementSection

                    // MARK: - About Section
                    aboutSection

                    // MARK: - Footer
                    footerView
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .alert("Clear All Data?", isPresented: $showClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear Everything", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This will permanently delete all \(photos.count) photos and their journal entries. This action cannot be undone.")
        }
        .sheet(isPresented: $showExportSheet) {
            ExportDataView(photos: photos, themeManager: themeManager)
        }
    }

    // MARK: - App Logo Header

    private var appLogoHeader: some View {
        VStack(spacing: 14) {
            // App Icon
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [themeManager.primaryLight, themeManager.primary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 76, height: 76)
                    .shadow(color: themeManager.primary.opacity(0.3), radius: 10, x: 0, y: 5)

                Image(systemName: "map.fill")
                    .font(.system(size: 34))
                    .foregroundColor(.white)
            }

            // Title with compass icons
            HStack(spacing: 10) {
                Image(systemName: "safari.fill")
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.accent)

                Text("Settings")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(themeManager.primary)

                Image(systemName: "safari.fill")
                    .font(.system(size: 18))
                    .foregroundColor(themeManager.accent)
            }

            Text("Customize your WanderState experience")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.primary.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Theme Section

    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 6) {
                Image(systemName: "paintpalette.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.primary)

                Text("APPEARANCE")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.primary)
            }
            .padding(.horizontal, 4)

            // Light/Dark Mode Picker
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(themeManager.accent.opacity(0.15))
                            .frame(width: 36, height: 36)

                        Image(systemName: themeManager.appearanceMode.icon)
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.accent)
                    }

                    Text("Display Mode")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)

                // Segmented picker
                Picker("Appearance", selection: $themeManager.appearanceMode) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.displayName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.tertiaryBackground)
            )

            // Color Theme label
            Text("Color Theme")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 4)
                .padding(.top, 4)

            // Theme Cards
            VStack(spacing: 8) {
                ForEach(ColorTheme.allCases) { theme in
                    ThemeCard(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme,
                        themeManager: themeManager
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            themeManager.currentTheme = theme
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 6) {
                Image(systemName: "externaldrive.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.secondary)

                Text("DATA MANAGEMENT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.secondary)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                // Storage Info
                SettingsRow(
                    icon: "photo.stack.fill",
                    iconColor: themeManager.primary,
                    title: "Photos Stored",
                    value: "\(photos.count)"
                )

                Divider()
                    .padding(.leading, 52)

                SettingsRow(
                    icon: "internaldrive.fill",
                    iconColor: themeManager.secondary,
                    title: "Storage Used",
                    value: calculateStorageUsed()
                )

                Divider()
                    .padding(.leading, 52)

                // Export Data Button
                Button(action: { showExportSheet = true }) {
                    SettingsRow(
                        icon: "square.and.arrow.up.fill",
                        iconColor: themeManager.accent,
                        title: "Export Data",
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 52)

                // Clear Data Button
                Button(action: { showClearDataAlert = true }) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.red.opacity(0.15))
                                .frame(width: 36, height: 36)

                            Image(systemName: "trash.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }

                        Text("Clear All Data")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.red)

                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.tertiaryBackground)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.accent)

                Text("ABOUT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.accent)
            }
            .padding(.horizontal, 4)

            VStack(spacing: 0) {
                SettingsRow(
                    icon: "app.badge.fill",
                    iconColor: themeManager.primary,
                    title: "Version",
                    value: appVersion
                )

                Divider()
                    .padding(.leading, 52)

                SettingsRow(
                    icon: "hammer.fill",
                    iconColor: themeManager.secondary,
                    title: "Build",
                    value: buildNumber
                )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.tertiaryBackground)
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 8) {
            Text("Made with ❤️ for travelers")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Text("© 2026 WanderState")
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Helper Functions

    private func calculateStorageUsed() -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("Photos")

        guard let contents = try? FileManager.default.contentsOfDirectory(at: photosPath, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 KB"
        }

        var totalSize: Int64 = 0
        for url in contents {
            if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                totalSize += Int64(size)
            }
        }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalSize)
    }

    private func clearAllData() {
        // Delete all photo entities from SwiftData
        for photo in photos {
            modelContext.delete(photo)
        }

        // Clear the Photos directory on disk
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("Photos")

        try? FileManager.default.removeItem(at: photosPath)
        try? FileManager.default.createDirectory(at: photosPath, withIntermediateDirectories: true)

        // Save the context
        try? modelContext.save()
    }
}

// MARK: - Theme Card

struct ThemeCard: View {
    let theme: ColorTheme
    let isSelected: Bool
    let themeManager: ThemeManager
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                // Color swatches in a row
                HStack(spacing: 3) {
                    ForEach(theme.swatchColors, id: \.self) { color in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(themeManager.tertiaryBackground)
                )

                // Theme info
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(theme.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? theme.primary : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(theme.primary)
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? theme.primary.opacity(0.08) : themeManager.tertiaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? theme.primary.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var value: String? = nil
    var showChevron: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)

            Spacer()

            if let value = value {
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
    }
}

// MARK: - Export Data View

struct ExportDataView: View {
    let photos: [PhotoEntity]
    let themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Icon
                ZStack {
                    Circle()
                        .fill(themeManager.primary.opacity(0.15))
                        .frame(width: 100, height: 100)

                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.primary)
                }

                VStack(spacing: 8) {
                    Text("Export Your Data")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)

                    Text("Export \(photos.count) photos and their journal entries")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Export Options
                VStack(spacing: 12) {
                    ExportOptionButton(
                        icon: "doc.zipper",
                        title: "Export as ZIP",
                        subtitle: "Photos + JSON metadata",
                        color: themeManager.primary
                    ) {
                        // Export functionality
                        dismiss()
                    }

                    ExportOptionButton(
                        icon: "doc.text.fill",
                        title: "Export Journal Only",
                        subtitle: "Text file with all entries",
                        color: themeManager.secondary
                    ) {
                        // Export functionality
                        dismiss()
                    }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Export Option Button

struct ExportOptionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    SettingsScreen()
        .modelContainer(for: [PhotoEntity.self, JournalEntryEntity.self], inMemory: true)
}
