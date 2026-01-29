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

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: photo.capturedDate)
    }

    private var locationText: String {
        if photo.cityName.isEmpty {
            return photo.stateName
        } else {
            return "\(photo.cityName), \(photo.stateName)"
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Full-size photo
                photoSection

                // Details section
                detailsSection
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle(photo.stateName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        Group {
            if let image = loadImage(from: photo.uri) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 300)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Image not found")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            }
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Location
            DetailRow(
                icon: "mappin.circle.fill",
                iconColor: .red,
                title: "Location",
                value: locationText
            )

            Divider()

            // Date
            DetailRow(
                icon: "calendar.circle.fill",
                iconColor: .blue,
                title: "Date",
                value: formattedDate
            )

            // Journal entry (if exists)
            if let journal = photo.journalEntry, !journal.entryText.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Journal Entry")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text(journal.entryText)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(16)
    }

    private func loadImage(from path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PhotoDetailView(photo: PhotoEntity(
            uri: "",
            stateCode: "PA",
            stateName: "Pennsylvania",
            cityName: "Philadelphia",
            latitude: 0,
            longitude: 0,
            capturedDate: Date()
        ))
    }
}
