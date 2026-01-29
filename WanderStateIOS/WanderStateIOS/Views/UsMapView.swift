//
//  UsMapView.swift
//  WanderStateIOS
//
//  Created by user946723 on 1/28/26.
//

import SwiftUI

// MARK: - US Map View

struct UsMapView: View {
    @State private var states: [StateInfo]
    @State private var selectedState: StateInfo?
    @State private var showStatePopup: Bool = false
    @State private var showAddPhotoSheet: Bool = false

    // Zoom and pan state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // SVG viewBox dimensions from the original file
    private let viewBoxWidth: CGFloat = 959
    private let viewBoxHeight: CGFloat = 593

    init(states: [StateInfo]? = nil) {
        _states = State(initialValue: states ?? StatePathData.allStates)
    }

    var body: some View {
        GeometryReader { geometry in
            // Add minimal padding so map fills most of the screen
            let padding: CGFloat = 12
            let availableWidth = geometry.size.width - (padding * 2)
            let availableHeight = geometry.size.height - (padding * 2)

            // Calculate scale to fit map in available space (aspect-fit)
            let fitScale = min(
                availableWidth / viewBoxWidth,
                availableHeight / viewBoxHeight
            )

            // Final dimensions after scaling
            let mapWidth = viewBoxWidth * fitScale * scale
            let mapHeight = viewBoxHeight * fitScale * scale

            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                // Map container - centered in available space
                ZStack {
                    ForEach(states) { state in
                        stateShape(for: state, mapWidth: mapWidth, mapHeight: mapHeight)
                    }
                }
                .frame(width: mapWidth, height: mapHeight)
                .position(
                    x: geometry.size.width / 2 + offset.width,
                    y: geometry.size.height / 2 + offset.height
                )
                .gesture(dragGesture)
                .gesture(magnificationGesture)
                .onTapGesture {
                    withAnimation {
                        showStatePopup = false
                        selectedState = nil
                    }
                }

                // State name popup - positioned at top with safe area consideration
                if showStatePopup, let state = selectedState {
                    VStack {
                        statePopup(for: state)
                            .padding(.top, 8)
                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $showAddPhotoSheet) {
                if let state = selectedState {
                    AddPhotoView(stateCode: state.stateCode)
                }
            }
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

            // Stroke overlay
            ScaledStateShape(pathData: state.pathData, viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight)
                .stroke(isSelected ? Color.blue : Color.white, lineWidth: isSelected ? 2 : 0.75)

            ForEach(state.additionalPaths.indices, id: \.self) { index in
                ScaledStateShape(pathData: state.additionalPaths[index], viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight)
                    .stroke(isSelected ? Color.blue : Color.white, lineWidth: isSelected ? 2 : 0.75)
            }
        }
        .contentShape(ScaledStateShape(pathData: state.pathData, viewBoxWidth: viewBoxWidth, viewBoxHeight: viewBoxHeight))
        .onTapGesture {
            handleStateTap(state)
        }
    }

    // MARK: - Popup View

    private func statePopup(for state: StateInfo) -> some View {
        VStack(spacing: 10) {
            Text(state.name)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)

            HStack(spacing: 4) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Text("\(state.photoCount) photo\(state.photoCount == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Button(action: {
                showAddPhotoSheet = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("Add Photo")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 0.5)
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
                showStatePopup.toggle()
            } else {
                selectedState = state
                showStatePopup = true
            }
        }
    }

    private func fillColor(for photoCount: Int) -> Color {
        switch photoCount {
        case 0:
            return Color(hex: "CCCCCC")  // Gray - not visited
        case 1...10:
            return Color(hex: "90EE90")  // Light green
        case 11...25:
            return Color(hex: "32CD32")  // Medium green
        default:
            return Color(hex: "228B22")  // Dark green
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

// MARK: - Preview

#Preview {
    UsMapView()
}
