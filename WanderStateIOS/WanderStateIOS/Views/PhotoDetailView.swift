//
//  PhotoDetailView.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import SwiftData

struct PhotoDetailView: View {
    let photo: PhotoEntity
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var themeManager = ThemeManager.shared

    // Edit states
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false

    // Formatted date: "Mar 12, 2024 • 1:41 PM"
    private var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        let dateString = dateFormatter.string(from: photo.capturedDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let timeString = timeFormatter.string(from: photo.capturedDate)

        return "\(dateString) • \(timeString)"
    }

    // Location header: "City, ST" or just state code
    private var locationHeader: String {
        if photo.cityName.isEmpty {
            return photo.stateCode
        } else {
            return "\(photo.cityName), \(photo.stateCode)"
        }
    }

    // Journal last updated date
    private var journalUpdatedDate: String? {
        guard let journal = photo.journalEntry else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: journal.updatedDate)
    }

    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Photo Card
                    photoCard

                    // MARK: - Details Card
                    detailsCard

                    // MARK: - Journal Card
                    if let journal = photo.journalEntry, !journal.entryText.isEmpty {
                        journalCard(journal: journal)
                    }

                    // Bottom spacing for action buttons
                    Spacer()
                        .frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }

            // MARK: - Bottom Action Buttons
            VStack {
                Spacer()
                actionButtonsBar
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(photo.stateName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showEditSheet = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(themeManager.primary)
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditPhotoView(photo: photo, themeManager: themeManager)
        }
        .sheet(isPresented: $showShareSheet) {
            if let image = loadImage(from: photo.uri) {
                ShareSheet(items: [image])
            }
        }
        .alert("Delete Photo?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deletePhoto()
            }
        } message: {
            Text("This will permanently delete this photo and its journal entry.")
        }
    }

    // MARK: - Photo Card

    private var photoCard: some View {
        VStack(spacing: 0) {
            // Photo with header overlay
            ZStack(alignment: .bottomLeading) {
                if let image = loadImage(from: photo.uri) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 280)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 280)
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "photo")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("Image not found")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                }

                // Gradient overlay for text readability
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 120)
                .frame(maxWidth: .infinity, alignment: .bottom)

                // Location header overlay
                VStack(alignment: .leading, spacing: 4) {
                    Text(locationHeader)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(photo.stateName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }

    // MARK: - Details Card

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date Row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(themeManager.primary.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Date Captured")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    Text(formattedDate)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }

                Spacer()
            }

            Divider()

            // Location Row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(themeManager.secondary.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.secondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Location")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)

                    Text(photo.cityName.isEmpty ? photo.stateName : "\(photo.cityName), \(photo.stateName)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                }

                Spacer()
            }

            // Coordinates (if available)
            if photo.latitude != 0 || photo.longitude != 0 {
                Divider()

                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(themeManager.accent.opacity(0.15))
                            .frame(width: 40, height: 40)

                        Image(systemName: "location.circle")
                            .font(.system(size: 18))
                            .foregroundColor(themeManager.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Coordinates")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)

                        Text(String(format: "%.4f, %.4f", photo.latitude, photo.longitude))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }

                    Spacer()
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

    // MARK: - Journal Card

    private func journalCard(journal: JournalEntryEntity) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.primary)

                Text("Journal Entry")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primary)

                Spacer()

                Button(action: { showEditSheet = true }) {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.secondary)
                }
            }

            // Journal text
            Text(journal.entryText)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            // Last updated
            if let updatedDate = journalUpdatedDate {
                Text("Last updated: \(updatedDate)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.primary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Action Buttons Bar

    private var actionButtonsBar: some View {
        HStack(spacing: 32) {
            // Edit Button
            ActionButton(
                icon: "pencil",
                label: "Edit",
                color: themeManager.primary
            ) {
                showEditSheet = true
            }

            // Share Button
            ActionButton(
                icon: "square.and.arrow.up",
                label: "Share",
                color: themeManager.secondary
            ) {
                showShareSheet = true
            }

            // Delete Button
            ActionButton(
                icon: "trash",
                label: "Delete",
                color: Color(hex: "E53935")
            ) {
                showDeleteAlert = true
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    // MARK: - Helper Functions

    private func loadImage(from path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }

    private func deletePhoto() {
        modelContext.delete(photo)
        dismiss()
    }
}

// MARK: - Action Button

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Edit Photo View

struct EditPhotoView: View {
    let photo: PhotoEntity
    let themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var cityName: String = ""
    @State private var journalText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("City Name", text: $cityName)
                } header: {
                    Text("Location")
                }

                Section {
                    TextEditor(text: $journalText)
                        .frame(minHeight: 150)
                } header: {
                    Text("Journal Entry")
                } footer: {
                    Text("Write about your memories from this place")
                }
            }
            .navigationTitle("Edit Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.primary)
                }
            }
            .onAppear {
                cityName = photo.cityName
                journalText = photo.journalEntry?.entryText ?? ""
            }
        }
    }

    private func saveChanges() {
        photo.cityName = cityName

        if !journalText.isEmpty {
            if let journal = photo.journalEntry {
                journal.entryText = journalText
                journal.updatedDate = Date()
            } else {
                let newJournal = JournalEntryEntity(
                    photoId: photo.id,
                    entryText: journalText
                )
                photo.journalEntry = newJournal
            }
        } else if let journal = photo.journalEntry {
            modelContext.delete(journal)
            photo.journalEntry = nil
        }

        dismiss()
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PhotoDetailView(photo: PhotoEntity(
            uri: "",
            stateCode: "CA",
            stateName: "California",
            cityName: "Mount Shasta",
            latitude: 41.3099,
            longitude: -122.3106,
            capturedDate: Date()
        ))
    }
}
