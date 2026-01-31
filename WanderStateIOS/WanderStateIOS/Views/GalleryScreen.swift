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
    @State private var navigationManager = NavigationManager.shared
    @State private var showFilterMenu = false
    @State private var sortOrder: SortOrder = .dateNewest
    @State private var groupByState = true

    // Filtered photos based on state filter
    private var filteredPhotos: [PhotoEntity] {
        if let stateFilter = navigationManager.galleryStateFilter {
            return photos.filter { $0.stateName == stateFilter }
        }
        return photos
    }

    // Group photos by state
    private var photosByState: [(state: String, photos: [PhotoEntity])] {
        let grouped = Dictionary(grouping: filteredPhotos) { $0.stateName }
        return grouped.map { (state: $0.key, photos: $0.value) }
            .sorted { $0.state < $1.state }
    }

    // Sorted photos (flat list)
    private var sortedPhotos: [PhotoEntity] {
        switch sortOrder {
        case .dateNewest:
            return filteredPhotos.sorted { $0.addedDate > $1.addedDate }
        case .dateOldest:
            return filteredPhotos.sorted { $0.addedDate < $1.addedDate }
        case .stateName:
            return filteredPhotos.sorted { $0.stateName < $1.stateName }
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
                    if filteredPhotos.isEmpty {
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
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    // Show state name if filtering, otherwise "Photo Gallery"
                    if let stateFilter = navigationManager.galleryStateFilter {
                        HStack(spacing: 8) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(themeManager.accent)

                            Text(stateFilter)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeManager.primary)

                            Button(action: {
                                withAnimation {
                                    navigationManager.clearGalleryFilter()
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.secondary.opacity(0.6))
                            }
                        }
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.accent)

                            Text("Photo Gallery")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeManager.primary)
                        }
                    }

                    Text("\(filteredPhotos.count) photo\(filteredPhotos.count == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.leading, 2)
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

                    if navigationManager.galleryStateFilter != nil {
                        Section {
                            Button(action: { navigationManager.clearGalleryFilter() }) {
                                Label("Show All States", systemImage: "map")
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(themeManager.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 10)

            // Subtle divider
            Rectangle()
                .fill(themeManager.primary.opacity(0.1))
                .frame(height: 1)
        }
        .background(themeManager.cardBackground)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()

            // Icon in a circle
            ZStack {
                Circle()
                    .fill(themeManager.primary.opacity(0.1))
                    .frame(width: 120, height: 120)

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundColor(themeManager.primary.opacity(0.6))
            }

            Text("No Photos Yet")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(themeManager.primary)

            if navigationManager.galleryStateFilter != nil {
                Text("No photos from this state yet.\nTap a state on the map to add photos!")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Button(action: {
                    navigationManager.clearGalleryFilter()
                }) {
                    Text("View All Photos")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(themeManager.primary, lineWidth: 1.5)
                        )
                }
                .padding(.top, 8)
            } else {
                Text("Tap a state on the map to add\nyour first travel photo!")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 40)
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
        LazyVStack(alignment: .leading, spacing: 20) {
            ForEach(photosByState, id: \.state) { group in
                VStack(alignment: .leading, spacing: 10) {
                    // Section Header with state icon
                    HStack(spacing: 8) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.accent)

                        Text(group.state)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(themeManager.primary)

                        Text("\(group.photos.count)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(themeManager.secondary)
                            )

                        Spacer()
                    }
                    .padding(.horizontal, 18)

                    // Photo Grid for this state
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(group.photos) { photo in
                            NavigationLink(destination: PhotoDetailView(photo: photo)) {
                                PhotoCard(photo: photo, themeManager: themeManager)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14)
                }
            }
            .padding(.bottom, 6)
        }
        .padding(.top, 12)
        .padding(.bottom, 20)
    }

    // MARK: - Flat Grid View

    private var flatPhotoGridView: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(sortedPhotos) { photo in
                NavigationLink(destination: PhotoDetailView(photo: photo)) {
                    PhotoCard(photo: photo, themeManager: themeManager)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 20)
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
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: photo.capturedDate)
    }

    private var locationText: String {
        if !photo.cityName.isEmpty {
            return "\(photo.cityName), \(photo.stateCode)"
        }
        return photo.stateCode
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo Thumbnail with overlays
            ZStack {
                // Photo Image
                if let image = loadImage(from: photo.uri) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 130)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(themeManager.primary.opacity(0.08))
                        .frame(height: 130)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 28))
                                .foregroundColor(themeManager.primary.opacity(0.3))
                        )
                }

                // Gradient overlay for text readability
                VStack {
                    // Top gradient
                    LinearGradient(
                        colors: [.black.opacity(0.5), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 40)

                    Spacer()

                    // Bottom gradient
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 30)
                }

                // Location overlay (top-left)
                VStack {
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin")
                                .font(.system(size: 9, weight: .bold))
                            Text(locationText)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.55))
                        )
                        .padding(6)

                        Spacer()
                    }
                    Spacer()
                }

                // Edit icon (bottom-right)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                            .padding(6)
                    }
                }
            }
            .frame(height: 130)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 12
                )
            )

            // Date and info bar below photo
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 10))
                    .foregroundColor(themeManager.secondary)

                Text(formattedDate)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                // Journal indicator
                if photo.journalEntry != nil {
                    HStack(spacing: 3) {
                        Image(systemName: "note.text")
                            .font(.system(size: 10))
                        Text("Journal")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(themeManager.accent)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
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
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
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
