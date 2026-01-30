//
//  StatsScreen.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import SwiftData

struct StatsScreen: View {
    @Query(sort: \PhotoEntity.addedDate, order: .reverse) private var photos: [PhotoEntity]
    @State private var themeManager = ThemeManager.shared

    // MARK: - Computed Stats

    private var statesVisited: Int {
        Set(photos.map { $0.stateCode }).count
    }

    private var totalPhotos: Int {
        photos.count
    }

    private var progressPercentage: Double {
        Double(statesVisited) / 50.0
    }

    private var percentageText: String {
        let percent = Int(progressPercentage * 100)
        return "\(percent)%"
    }

    private var daysTracking: Int {
        guard let firstPhoto = photos.min(by: { $0.addedDate < $1.addedDate }) else {
            return 0
        }
        let days = Calendar.current.dateComponents([.day], from: firstPhoto.addedDate, to: Date()).day ?? 0
        return max(days, 1)
    }

    private var photosWithJournal: Int {
        photos.filter { $0.journalEntry != nil && !($0.journalEntry?.entryText.isEmpty ?? true) }.count
    }

    private var journalPercentage: String {
        guard totalPhotos > 0 else { return "0%" }
        let percent = Int((Double(photosWithJournal) / Double(totalPhotos)) * 100)
        return "\(percent)%"
    }

    private var stateWithMostPhotos: (code: String, count: Int)? {
        let grouped = Dictionary(grouping: photos) { $0.stateCode }
        guard let maxState = grouped.max(by: { $0.value.count < $1.value.count }) else {
            return nil
        }
        return (code: maxState.key, count: maxState.value.count)
    }

    private var motivationalText: String {
        switch statesVisited {
        case 0:
            return "Start your adventure! Add your first photo."
        case 1...10:
            return "Great start! Keep exploring to reach all 50!"
        case 11...25:
            return "You're on a roll! Halfway there!"
        case 26...40:
            return "Amazing progress! The finish line is in sight!"
        case 41...49:
            return "So close! Just \(50 - statesVisited) more to go!"
        case 50:
            return "Congratulations! You've explored all 50 states!"
        default:
            return "Keep exploring to reach all 50!"
        }
    }

    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    headerView

                    // MARK: - Progress Ring
                    progressRingCard

                    // MARK: - Key Metrics
                    keyMetricsSection

                    Spacer()
                        .frame(height: 20)
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your WanderStats")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.primary)

                Text("Track your journey across America")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.top, 16)
    }

    // MARK: - Progress Ring Card

    private var progressRingCard: some View {
        VStack(spacing: 20) {
            // Circular Progress Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(
                        themeManager.primary.opacity(0.15),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progressPercentage)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                themeManager.primaryLight,
                                themeManager.primary,
                                themeManager.primaryDark
                            ]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progressPercentage)

                // Center content
                VStack(spacing: 4) {
                    Text("\(statesVisited)")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundColor(themeManager.primary)

                    Text("of 50")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)

                    Text(percentageText)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.secondary)
                        .padding(.top, 2)
                }
            }
            .padding(.top, 8)

            // Labels
            VStack(spacing: 8) {
                Text("States Explored")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)

                Text(motivationalText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 8)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.cardBackground)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    // MARK: - Key Metrics Section

    private var keyMetricsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Metrics")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primary)
                .padding(.leading, 4)

            // 2x2 Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                // Total Photos
                MetricCard(
                    icon: "photo.fill",
                    value: "\(totalPhotos)",
                    label: "Total Photos",
                    color: themeManager.primary,
                    cardBackground: themeManager.cardBackground
                )

                // Days Tracking
                MetricCard(
                    icon: "calendar",
                    value: "\(daysTracking)",
                    label: "Days Tracking",
                    color: themeManager.secondary,
                    cardBackground: themeManager.cardBackground
                )

                // With Journal
                MetricCard(
                    icon: "note.text",
                    value: "\(photosWithJournal)",
                    subtitle: journalPercentage,
                    label: "With Journal",
                    color: themeManager.accent,
                    cardBackground: themeManager.cardBackground
                )

                // State with Most
                MetricCard(
                    icon: "star.fill",
                    value: stateWithMostPhotos?.code ?? "--",
                    subtitle: stateWithMostPhotos != nil ? "(\(stateWithMostPhotos!.count))" : "",
                    label: "Most Visited",
                    color: Color(hex: "FFC107"),
                    cardBackground: themeManager.cardBackground
                )
            }
        }
    }
}

// MARK: - Metric Card

struct MetricCard: View {
    let icon: String
    let value: String
    var subtitle: String? = nil
    let label: String
    let color: Color
    var cardBackground: Color = Color(UIColor.secondarySystemGroupedBackground)

    var body: some View {
        VStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }

            // Value
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)

                if let subtitle = subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(color)
                }
            }

            // Label
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackground)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    StatsScreen()
        .modelContainer(for: [PhotoEntity.self, JournalEntryEntity.self], inMemory: true)
}
