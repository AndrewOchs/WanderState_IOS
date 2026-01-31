//
//  UsMapView.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI
import SwiftData

// MARK: - US Map View

struct UsMapView: View {
    // SwiftData query for photos
    @Query(sort: \PhotoEntity.addedDate, order: .reverse) private var photos: [PhotoEntity]

    // Theme manager for dynamic colors
    @State private var themeManager = ThemeManager.shared
    @State private var navigationManager = NavigationManager.shared

    @State private var selectedState: StateInfo?
    @State private var showStatePopup: Bool = false
    @State private var showAddPhotoSheet: Bool = false
    @State private var showStateSelector: Bool = false

    // Zoom and pan state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // SVG viewBox dimensions from the original file
    private let viewBoxWidth: CGFloat = 959
    private let viewBoxHeight: CGFloat = 593

    // Compute states with photo counts from SwiftData
    private var statesWithPhotoCounts: [StateInfo] {
        let photoCounts = Dictionary(grouping: photos, by: { $0.stateCode })
            .mapValues { $0.count }

        return StatePathData.allStates.map { state in
            var updatedState = state
            updatedState.photoCount = photoCounts[state.id] ?? 0
            return updatedState
        }
    }

    // Stats computed properties
    private var statesVisitedCount: Int {
        Set(photos.map { $0.stateCode }).count
    }

    private var totalPhotosCount: Int {
        photos.count
    }

    var body: some View {
        GeometryReader { geometry in
            // Reserve space for header and legend
            let headerHeight: CGFloat = 95
            let legendHeight: CGFloat = 80
            let padding: CGFloat = 12

            let availableWidth = geometry.size.width - (padding * 2)
            let availableHeight = geometry.size.height - headerHeight - legendHeight - (padding * 2)

            // Calculate scale to fit map in available space (aspect-fit)
            let fitScale = min(
                availableWidth / viewBoxWidth,
                availableHeight / viewBoxHeight
            )

            // Final dimensions after scaling
            let mapWidth = viewBoxWidth * fitScale * scale
            let mapHeight = viewBoxHeight * fitScale * scale

            ZStack {
                themeManager.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // MARK: - Header Card
                    VStack(spacing: 6) {
                        // Title with compass icons
                        HStack(spacing: 10) {
                            Image(systemName: "safari.fill")
                                .font(.system(size: 18))
                                .foregroundColor(themeManager.accent)

                            Text("My WanderState Map")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(themeManager.primary)

                            Image(systemName: "safari.fill")
                                .font(.system(size: 18))
                                .foregroundColor(themeManager.accent)
                        }

                        // Stats line
                        Text("\(statesVisitedCount) states visited • \(totalPhotosCount) total photos")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(themeManager.cardBackground)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.primary.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                    // MARK: - Map Container
                    ZStack {
                        // Map content
                        ZStack {
                            ForEach(statesWithPhotoCounts) { state in
                                stateShape(for: state, mapWidth: mapWidth, mapHeight: mapHeight)
                            }
                        }
                        .frame(width: mapWidth, height: mapHeight)
                        .position(
                            x: availableWidth / 2 + padding + offset.width,
                            y: availableHeight / 2 + offset.height
                        )
                        .gesture(dragGesture)
                        .gesture(magnificationGesture)
                        .onTapGesture {
                            withAnimation {
                                showStatePopup = false
                                selectedState = nil
                            }
                        }

                        // State popup overlay
                        if showStatePopup, let state = selectedState {
                            let currentPhotoCount = photoCount(for: state.id)
                            VStack {
                                statePopup(for: state, photoCount: currentPhotoCount)
                                    .padding(.top, 8)
                                Spacer()
                            }
                        }
                    }
                    .frame(height: availableHeight)

                    // MARK: - Color Legend
                    colorLegend
                        .frame(height: legendHeight)
                }

                // MARK: - Floating Camera Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showStateSelector = true
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(themeManager.accent)
                                .clipShape(Circle())
                                .shadow(color: themeManager.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, legendHeight + 20)
                    }
                }
            }
            .sheet(isPresented: $showAddPhotoSheet) {
                if let state = selectedState {
                    AddPhotoView(stateCode: state.stateCode)
                }
            }
            .sheet(isPresented: $showStateSelector) {
                StateSelectorSheet(
                    states: statesWithPhotoCounts,
                    themeManager: themeManager
                ) { state in
                    selectedState = state
                    showStateSelector = false
                    showAddPhotoSheet = true
                }
            }
        }
    }

    // MARK: - Color Legend View

    private var colorLegend: some View {
        VStack(spacing: 8) {
            Text("Photo Count")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                legendItem(color: themeManager.currentTheme.stateUnvisited, label: "0")
                legendItem(color: themeManager.currentTheme.stateVisitedLight, label: "1-10")
                legendItem(color: themeManager.currentTheme.stateVisitedMedium, label: "11-25")
                legendItem(color: themeManager.currentTheme.stateVisitedDark, label: "25+")
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 20, height: 20)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white, lineWidth: 1)
                )

            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
    }

    // MARK: - State Shape Builder

    @ViewBuilder
    private func stateShape(for state: StateInfo, mapWidth: CGFloat, mapHeight: CGFloat) -> some View {
        let color = fillColor(for: state.photoCount)
        let isSelected = selectedState?.id == state.id

        ZStack {
            // Main path
            ScaledStateShape(pathData: state.pathData, viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight)
                .fill(color)

            // Additional paths (for states like Michigan with multiple regions)
            ForEach(state.additionalPaths.indices, id: \.self) { index in
                ScaledStateShape(pathData: state.additionalPaths[index], viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight)
                    .fill(color)
            }

            // Stroke overlay - uses theme background for subtle borders
            ScaledStateShape(pathData: state.pathData, viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight)
                .stroke(isSelected ? themeManager.primary : themeManager.background, lineWidth: isSelected ? 2.5 : 0.75)

            ForEach(state.additionalPaths.indices, id: \.self) { index in
                ScaledStateShape(pathData: state.additionalPaths[index], viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight)
                    .stroke(isSelected ? themeManager.primary : themeManager.background, lineWidth: isSelected ? 2.5 : 0.75)
            }
        }
        .contentShape(ScaledStateShape(pathData: state.pathData, viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight))
        .onTapGesture {
            handleStateTap(state)
        }
    }

    // MARK: - Photo Count Helper

    private func photoCount(for stateCode: String) -> Int {
        photos.filter { $0.stateCode == stateCode }.count
    }

    // MARK: - Popup View

    private func statePopup(for state: StateInfo, photoCount: Int) -> some View {
        VStack(spacing: 4) {
            // State name with photo count - compact single line
            HStack(spacing: 4) {
                Text(state.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(themeManager.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text("•")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Image(systemName: "photo.fill")
                    .font(.system(size: 9))
                    .foregroundColor(themeManager.secondary)
                Text("\(photoCount)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .fixedSize(horizontal: true, vertical: false)

            // Compact buttons row
            HStack(spacing: 6) {
                // Add Photo button
                Button(action: {
                    showAddPhotoSheet = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 10))
                        Text("Add")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(themeManager.primary)
                    .cornerRadius(12)
                }

                // View Photos button (only if photos exist)
                if photoCount > 0 {
                    Button(action: {
                        showStatePopup = false
                        navigationManager.navigateToGallery(forState: state.name)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 10))
                            Text("View")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(themeManager.primary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.primary, lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.cardBackground)
                .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.primary.opacity(0.1), lineWidth: 0.5)
        )
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale = min(max(newScale, 0.5), 5.0)
            }
            .onEnded { _ in
                lastScale = scale
            }
    }

    // MARK: - Helpers

    private func handleStateTap(_ state: StateInfo) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if selectedState?.id == state.id {
                // Tapping same state - close popup and deselect
                showStatePopup = false
                selectedState = nil
            } else {
                // Tapping new state - select and show popup
                selectedState = state
                showStatePopup = true
            }
        }
    }

    private func fillColor(for photoCount: Int) -> Color {
        let theme = themeManager.currentTheme
        switch photoCount {
        case 0:
            return theme.stateUnvisited  // Gray - not visited
        case 1...10:
            return theme.stateVisitedLight  // Light shade
        case 11...25:
            return theme.stateVisitedMedium  // Medium shade
        default:
            return theme.stateVisitedDark  // Dark shade
        }
    }
}

// MARK: - Scaled State Shape

/// A Shape that renders SVG path data scaled to fit its frame
struct ScaledStateShape: Shape {
    let pathData: String
    let viewBoxWidth: CGFloat
    let viewBoxHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        // Parse the SVG path at original SVG coordinates (0-959, 0-593)
        let originalPath = SVGPathParser.parse(pathData)

        // The rect we receive is the frame size (mapWidth x mapHeight)
        // We need to scale from viewBox coordinates to rect coordinates
        let scaleX = rect.width / viewBoxWidth
        let scaleY = rect.height / viewBoxHeight

        // Use uniform scaling to maintain aspect ratio
        let uniformScale = min(scaleX, scaleY)

        // Apply scaling transform
        var transform = CGAffineTransform.identity
        transform = transform.scaledBy(x: uniformScale, y: uniformScale)

        return originalPath.applying(transform)
    }
}

// MARK: - SVG Path Parser

struct SVGPathParser {

    static func parse(_ pathData: String) -> Path {
        var path = Path()
        let tokens = tokenize(pathData)

        var index = 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var startX: CGFloat = 0
        var startY: CGFloat = 0
        var lastControlX: CGFloat = 0
        var lastControlY: CGFloat = 0
        var lastCommand: Character = " "

        while index < tokens.count {
            let token = tokens[index]

            if let command = token.first, command.isLetter {
                index += 1
                lastCommand = command

                switch command {
                case "M":
                    guard index + 1 < tokens.count else { break }
                    currentX = CGFloat(Double(tokens[index]) ?? 0)
                    currentY = CGFloat(Double(tokens[index + 1]) ?? 0)
                    path.move(to: CGPoint(x: currentX, y: currentY))
                    startX = currentX
                    startY = currentY
                    index += 2
                    while index + 1 < tokens.count,
                          let x = Double(tokens[index]),
                          let y = Double(tokens[index + 1]),
                          !tokens[index].first!.isLetter {
                        currentX = CGFloat(x)
                        currentY = CGFloat(y)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 2
                    }

                case "m":
                    guard index + 1 < tokens.count else { break }
                    currentX += CGFloat(Double(tokens[index]) ?? 0)
                    currentY += CGFloat(Double(tokens[index + 1]) ?? 0)
                    path.move(to: CGPoint(x: currentX, y: currentY))
                    startX = currentX
                    startY = currentY
                    index += 2
                    while index + 1 < tokens.count,
                          let dx = Double(tokens[index]),
                          let dy = Double(tokens[index + 1]),
                          !tokens[index].first!.isLetter {
                        currentX += CGFloat(dx)
                        currentY += CGFloat(dy)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 2
                    }

                case "L":
                    while index + 1 < tokens.count,
                          let x = Double(tokens[index]),
                          let y = Double(tokens[index + 1]) {
                        currentX = CGFloat(x)
                        currentY = CGFloat(y)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 2
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "l":
                    while index + 1 < tokens.count,
                          let dx = Double(tokens[index]),
                          let dy = Double(tokens[index + 1]) {
                        currentX += CGFloat(dx)
                        currentY += CGFloat(dy)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 2
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "H":
                    while index < tokens.count, let x = Double(tokens[index]) {
                        currentX = CGFloat(x)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 1
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "h":
                    while index < tokens.count, let dx = Double(tokens[index]) {
                        currentX += CGFloat(dx)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 1
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "V":
                    while index < tokens.count, let y = Double(tokens[index]) {
                        currentY = CGFloat(y)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 1
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "v":
                    while index < tokens.count, let dy = Double(tokens[index]) {
                        currentY += CGFloat(dy)
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 1
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "C":
                    while index + 5 < tokens.count,
                          let x1 = Double(tokens[index]),
                          let y1 = Double(tokens[index + 1]),
                          let x2 = Double(tokens[index + 2]),
                          let y2 = Double(tokens[index + 3]),
                          let x = Double(tokens[index + 4]),
                          let y = Double(tokens[index + 5]) {
                        path.addCurve(
                            to: CGPoint(x: x, y: y),
                            control1: CGPoint(x: x1, y: y1),
                            control2: CGPoint(x: x2, y: y2)
                        )
                        lastControlX = CGFloat(x2)
                        lastControlY = CGFloat(y2)
                        currentX = CGFloat(x)
                        currentY = CGFloat(y)
                        index += 6
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "c":
                    while index + 5 < tokens.count,
                          let dx1 = Double(tokens[index]),
                          let dy1 = Double(tokens[index + 1]),
                          let dx2 = Double(tokens[index + 2]),
                          let dy2 = Double(tokens[index + 3]),
                          let dx = Double(tokens[index + 4]),
                          let dy = Double(tokens[index + 5]) {
                        let x1 = currentX + CGFloat(dx1)
                        let y1 = currentY + CGFloat(dy1)
                        let x2 = currentX + CGFloat(dx2)
                        let y2 = currentY + CGFloat(dy2)
                        let x = currentX + CGFloat(dx)
                        let y = currentY + CGFloat(dy)
                        path.addCurve(
                            to: CGPoint(x: x, y: y),
                            control1: CGPoint(x: x1, y: y1),
                            control2: CGPoint(x: x2, y: y2)
                        )
                        lastControlX = x2
                        lastControlY = y2
                        currentX = x
                        currentY = y
                        index += 6
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "S":
                    while index + 3 < tokens.count,
                          let x2 = Double(tokens[index]),
                          let y2 = Double(tokens[index + 1]),
                          let x = Double(tokens[index + 2]),
                          let y = Double(tokens[index + 3]) {
                        let x1 = currentX * 2 - lastControlX
                        let y1 = currentY * 2 - lastControlY
                        path.addCurve(
                            to: CGPoint(x: x, y: y),
                            control1: CGPoint(x: x1, y: y1),
                            control2: CGPoint(x: x2, y: y2)
                        )
                        lastControlX = CGFloat(x2)
                        lastControlY = CGFloat(y2)
                        currentX = CGFloat(x)
                        currentY = CGFloat(y)
                        index += 4
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "s":
                    while index + 3 < tokens.count,
                          let dx2 = Double(tokens[index]),
                          let dy2 = Double(tokens[index + 1]),
                          let dx = Double(tokens[index + 2]),
                          let dy = Double(tokens[index + 3]) {
                        let x1 = currentX * 2 - lastControlX
                        let y1 = currentY * 2 - lastControlY
                        let x2 = currentX + CGFloat(dx2)
                        let y2 = currentY + CGFloat(dy2)
                        let x = currentX + CGFloat(dx)
                        let y = currentY + CGFloat(dy)
                        path.addCurve(
                            to: CGPoint(x: x, y: y),
                            control1: CGPoint(x: x1, y: y1),
                            control2: CGPoint(x: x2, y: y2)
                        )
                        lastControlX = x2
                        lastControlY = y2
                        currentX = x
                        currentY = y
                        index += 4
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "Q":
                    while index + 3 < tokens.count,
                          let x1 = Double(tokens[index]),
                          let y1 = Double(tokens[index + 1]),
                          let x = Double(tokens[index + 2]),
                          let y = Double(tokens[index + 3]) {
                        path.addQuadCurve(
                            to: CGPoint(x: x, y: y),
                            control: CGPoint(x: x1, y: y1)
                        )
                        lastControlX = CGFloat(x1)
                        lastControlY = CGFloat(y1)
                        currentX = CGFloat(x)
                        currentY = CGFloat(y)
                        index += 4
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "q":
                    while index + 3 < tokens.count,
                          let dx1 = Double(tokens[index]),
                          let dy1 = Double(tokens[index + 1]),
                          let dx = Double(tokens[index + 2]),
                          let dy = Double(tokens[index + 3]) {
                        let x1 = currentX + CGFloat(dx1)
                        let y1 = currentY + CGFloat(dy1)
                        let x = currentX + CGFloat(dx)
                        let y = currentY + CGFloat(dy)
                        path.addQuadCurve(
                            to: CGPoint(x: x, y: y),
                            control: CGPoint(x: x1, y: y1)
                        )
                        lastControlX = x1
                        lastControlY = y1
                        currentX = x
                        currentY = y
                        index += 4
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "A", "a":
                    let isRelative = command == "a"
                    while index + 6 < tokens.count,
                          let _ = Double(tokens[index]),
                          let _ = Double(tokens[index + 1]),
                          let _ = Double(tokens[index + 2]),
                          let _ = Double(tokens[index + 3]),
                          let _ = Double(tokens[index + 4]),
                          let x = Double(tokens[index + 5]),
                          let y = Double(tokens[index + 6]) {
                        if isRelative {
                            currentX += CGFloat(x)
                            currentY += CGFloat(y)
                        } else {
                            currentX = CGFloat(x)
                            currentY = CGFloat(y)
                        }
                        path.addLine(to: CGPoint(x: currentX, y: currentY))
                        index += 7
                        if index < tokens.count && tokens[index].first?.isLetter == true { break }
                    }

                case "Z", "z":
                    path.closeSubpath()
                    currentX = startX
                    currentY = startY

                default:
                    break
                }
            } else {
                index += 1
            }
        }

        return path
    }

    private static func tokenize(_ pathData: String) -> [String] {
        var tokens: [String] = []
        var current = ""

        for char in pathData {
            if char.isLetter {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                tokens.append(String(char))
            } else if char == "," || char == " " || char == "\n" || char == "\t" {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
            } else if char == "-" {
                if !current.isEmpty {
                    tokens.append(current)
                }
                current = String(char)
            } else if char == "." {
                if current.contains(".") {
                    tokens.append(current)
                    current = "0."
                } else {
                    current.append(char)
                }
            } else {
                current.append(char)
            }
        }

        if !current.isEmpty {
            tokens.append(current)
        }

        return tokens
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - State Selector Sheet

struct StateSelectorSheet: View {
    let states: [StateInfo]
    let themeManager: ThemeManager
    let onStateSelected: (StateInfo) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredStates: [StateInfo] {
        if searchText.isEmpty {
            return states.sorted { $0.name < $1.name }
        }
        return states
            .filter { $0.name.localizedCaseInsensitiveContains(searchText) ||
                      $0.id.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredStates) { state in
                    Button(action: {
                        onStateSelected(state)
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(state.name)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Text("\(state.photoCount) photo\(state.photoCount == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: "camera.fill")
                                .foregroundColor(themeManager.primary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search states")
            .navigationTitle("Select a State")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Preview

#Preview {
    UsMapView()
}
