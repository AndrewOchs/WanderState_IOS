//
//  SettingsScreen.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

struct SettingsScreen: View {
    @State private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Color Theme Section
                Section {
                    ForEach(ColorTheme.allCases) { theme in
                        ThemeOptionRow(
                            theme: theme,
                            isSelected: themeManager.currentTheme == theme
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                themeManager.currentTheme = theme
                            }
                        }
                    }
                } header: {
                    Text("Color Theme")
                } footer: {
                    Text("Choose a color theme for the app")
                }

                // MARK: - Data Management Section
                Section {
                    NavigationLink {
                        DataManagementView()
                    } label: {
                        Label("Data Management", systemImage: "externaldrive")
                    }
                } header: {
                    Text("Storage")
                }

                // MARK: - About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Theme Option Row

struct ThemeOptionRow: View {
    let theme: ColorTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Color swatches
                HStack(spacing: 4) {
                    ForEach(theme.swatchColors, id: \.self) { color in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: 24, height: 24)
                    }
                }
                .padding(4)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)

                // Theme info
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    Text(theme.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.primary)
                        .font(.title2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Data Management View

struct DataManagementView: View {
    @State private var showingClearAlert = false
    @State private var photoCount: Int = 0

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Photos")
                    Spacer()
                    Text("\(photoCount)")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Storage Used")
                    Spacer()
                    Text(calculateStorageUsed())
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Statistics")
            }

            Section {
                Button(role: .destructive) {
                    showingClearAlert = true
                } label: {
                    Label("Clear All Data", systemImage: "trash")
                }
            } header: {
                Text("Reset")
            } footer: {
                Text("This will permanently delete all photos and journal entries")
            }
        }
        .navigationTitle("Data Management")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Clear All Data?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("This action cannot be undone. All your photos and journal entries will be permanently deleted.")
        }
        .onAppear {
            updateStats()
        }
    }

    private func calculateStorageUsed() -> String {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("Photos")

        guard let contents = try? FileManager.default.contentsOfDirectory(at: photosPath, includingPropertiesForKeys: [.fileSizeKey]) else {
            return "0 MB"
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

    private func updateStats() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("Photos")

        if let contents = try? FileManager.default.contentsOfDirectory(at: photosPath, includingPropertiesForKeys: nil) {
            photoCount = contents.filter { $0.pathExtension == "jpg" || $0.pathExtension == "jpeg" || $0.pathExtension == "png" }.count
        }
    }

    private func clearAllData() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("Photos")

        try? FileManager.default.removeItem(at: photosPath)
        try? FileManager.default.createDirectory(at: photosPath, withIntermediateDirectories: true)

        updateStats()
    }
}

#Preview {
    SettingsScreen()
}
