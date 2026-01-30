//
//  GalleryScreen.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import SwiftData

struct GalleryScreen: View {
    @Query(sort: \PhotoEntity.addedDate, order: .reverse) private var photos: [PhotoEntity]
    @State private var themeManager = ThemeManager.shared
    @State private var showFilterMenu = false
    @State private var sortOrder: SortOrder = .dateNewest
    @State private var groupByState = true

    // Group photos by state
    private var photosByState: [(state: String, photos: [PhotoEntity])] {
        let grouped = Dictionary(grouping: photos) { $0.stateName }
        return grouped.map { (state: $0.key, photos: $0.value) }
            .sorted { $0.state < $1.state }
    }

    // Sorted photos (flat list)
    private var sortedPhotos: [PhotoEntity] {
        switch sortOrder {
        case .dateNewest:
            return photos.sorted { $0.addedDate > $1.addedDate }
        case .dateOldest:
            return photos.sorted { $0.addedDate < $1.addedDate }
        case .stateName:
            return photos.sorted { $0.stateName < $1.stateName }
        }
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Custom Header
                    headerView

                    // MARK: - Content
                    if photos.isEmpty {
                        emptyStateView
                    } else {
                        photoContentView
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Photo Gallery")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.primary)

                Text("\(photos.count) photo\(photos.count == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Filter/Menu Button
            Menu {
                Section("Sort By") {
                    Button(action: { sortOrder = .dateNewest }) {
                        Label("Newest First", systemImage: sortOrder == .dateNewest ? "checkmark" : "")
                    }
                    Button(action: { sortOrder = .dateOldest }) {
                        Label("Oldest First", systemImage: sortOrder == .dateOldest ? "checkmark" : "")
                    }
                    Button(action: { sortOrder = .stateName }) {
                        Label("By State", systemImage: sortOrder == .stateName ? "checkmark" : "")
                    }
                }

                Section("Display") {
                    Button(action: { groupByState.toggle() }) {
                        Label(groupByState ? "Show All Photos" : "Group by State",
                              systemImage: groupByState ? "square.grid.2x2" : "folder")
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(themeManager.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
        .background(themeManager.background)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(themeManager.primary.opacity(0.4))

            Text("No Photos Yet")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)

            Text("Tap a state on the map to add your first travel photo!")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Photo Content

    private var photoContentView: some View {
        ScrollView {
            if groupByState {
                groupedPhotoView
            } else {
                flatPhotoGridView
            }
        }
    }

    // MARK: - Grouped by State View

    private var groupedPhotoView: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(photosByState, id: \.state) { group in
                VStack(alignment: .leading, spacing: 12) {
                    // Section Header
                    HStack {
                        Text(group.state)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(themeManager.primary)

                        Text("(\(group.photos.count))")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    // Photo Grid for this state
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(group.photos) { photo in
                            NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                PhotoCard(photo: photo, themeManager: themeManager)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 8)
        }
        .padding(.top, 8)
    }

    // MARK: - Flat Grid View

    private var flatPhotoGridView: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(sortedPhotos) { photo in
                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                    PhotoCard(photo: photo, themeManager: themeManager)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Sort Order

enum SortOrder {
    case dateNewest
    case dateOldest
    case stateName
}

// MARK: - Photo Card

struct PhotoCard: View {
    let photo: PhotoEntity
    let themeManager: ThemeManager

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: photo.capturedDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo Thumbnail with overlays
            ZStack(alignment: .topLeading) {
                // Photo Image
                if let image = loadImage(from: photo.uri) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 140)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 30))
                                .foregroundColor(.gray.opacity(0.5))
                        )
                }

                // State & City overlay (top-left)
                VStack(alignment: .leading, spacing: 2) {
                    Text(photo.stateName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)

                    if !photo.cityName.isEmpty {
                        Text(photo.cityName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.6))
                )
                .padding(8)

                // Edit icon (bottom-right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            .padding(8)
                    }
                }
            }
            .frame(height: 140)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 12
                )
            )

            // Date stamp below photo
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.secondary)

                Text(formattedDate)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                // Journal indicator
                if photo.journalEntry != nil {
                    Image(systemName: "note.text")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.accent)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .background(themeManager.cardBackground)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 12,
                    topTrailingRadius: 0
                )
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        )
    }

    private func loadImage(from path: String) -> UIImage? {
        return UIImage(contentsOfFile: path)
    }
}

// MARK: - Preview

#Preview {
    GalleryScreen()
        .modelContainer(for: [PhotoEntity.self, JournalEntryEntity.self], inMemory: true)
}
