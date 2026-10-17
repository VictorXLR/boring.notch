//
//  AnimatedFace.swift
//
//  Small, selectable faces for the closed notch.
//

import Defaults
import SwiftUI

struct MinimalFaceFeatures: View {
    @Default(.boringFaceStyle) private var savedFaceStyle
    @State private var isBlinking = false

    private let previewStyle: BoringFaceStyle?
    private let height: CGFloat
    private let width: CGFloat

    init(style: BoringFaceStyle? = nil, height: CGFloat = 20, width: CGFloat = 30) {
        self.previewStyle = style
        self.height = height
        self.width = width
    }

    private var activeStyle: BoringFaceStyle {
        previewStyle ?? savedFaceStyle
    }

    var body: some View {
        ZStack {
            faceContent
                .scaleEffect(min(width / 30, height / 20))
        }
        .frame(width: width, height: height)
        .onAppear {
            startBlinking()
        }
    }

    @ViewBuilder
    private var faceContent: some View {
        switch activeStyle {
        case .neonWink:
            NeonWinkFace(isBlinking: $isBlinking)
        case .sleepy:
            SleepyFace()
        case .pixelBot:
            PixelBotFace()
        case .starstruck:
            StarstruckFace()
        case .darthVader:
            DarthVaderFace()
        case .jasonVoorhees:
            JasonVoorheesFace()
        case .amongUs:
            AmongUsFace()
        }
    }

    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                isBlinking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isBlinking = false
                }
            }
        }
    }
}

struct BoringFaceRosterView: View {
    /// Maximum number of faces a roster can show at once.
    static let maxFaceCount = 3
    /// Spacing between faces when `fillsWidth` is `false`.
    static let spacing: CGFloat = 2

    let styles: [BoringFaceStyle]
    let personalityEnabled: Bool
    var faceWidth: CGFloat = 24
    var faceHeight: CGFloat = 18
    var fillsWidth: Bool = false

    private var visibleStyles: [BoringFaceStyle] {
        Self.resolvedStyles(styles)
    }

    /// The styles that actually render: de-duplicated, non-empty and capped at
    /// `maxFaceCount`. Callers use this so they never measure a roster wider
    /// than the one on screen.
    static func resolvedStyles(_ styles: [BoringFaceStyle]) -> [BoringFaceStyle] {
        var uniqueStyles: [BoringFaceStyle] = []
        for style in styles where !uniqueStyles.contains(style) {
            uniqueStyles.append(style)
        }
        return Array((uniqueStyles.isEmpty ? [.neonWink] : uniqueStyles).prefix(maxFaceCount))
    }

    /// Layout width of the roster when `fillsWidth` is `false`.
    static func intrinsicWidth(styles: [BoringFaceStyle], faceWidth: CGFloat) -> CGFloat {
        let count = CGFloat(resolvedStyles(styles).count)
        return count * faceWidth + max(0, count - 1) * spacing
    }

    var body: some View {
        Group {
            if fillsWidth {
                HStack(spacing: 0) {
                    Spacer(minLength: 0)
                    faceViews
                    Spacer(minLength: 0)
                }
            } else {
                faceViews
            }
        }
        .frame(height: faceHeight)
    }

    private var faceViews: some View {
        HStack(spacing: fillsWidth ? 0 : Self.spacing) {
            ForEach(Array(visibleStyles.enumerated()), id: \.element) { index, style in
                if fillsWidth && index > 0 {
                    Spacer(minLength: 18)
                }
                PersonalityFaceView(
                    style: style,
                    enabled: personalityEnabled,
                    width: faceWidth,
                    height: faceHeight
                )
            }
        }
    }
}

private struct PersonalityFaceView: View {
    let style: BoringFaceStyle
    let enabled: Bool
    let width: CGFloat
    let height: CGFloat

    @State private var isBlinking = false
    @State private var isWobbling = false
    @State private var isFallen = false
    @State private var personalityTask: Task<Void, Never>?

    var body: some View {
        MinimalFaceFeatures(style: style, height: height, width: width)
            .scaleEffect(y: isBlinking ? 0.12 : 1)
            .rotationEffect(.degrees(isFallen ? 88 : (isWobbling ? 5 : 0)))
            .offset(y: isFallen ? 3 : 0)
            .animation(.spring(response: 0.35, dampingFraction: 0.68), value: isBlinking)
            .animation(.spring(response: 0.45, dampingFraction: 0.65), value: isWobbling)
            .animation(.spring(response: 0.6, dampingFraction: 0.72), value: isFallen)
            .onAppear {
                startPersonality()
            }
            .onDisappear {
                personalityTask?.cancel()
                personalityTask = nil
            }
    }

    private func startPersonality() {
        guard enabled, personalityTask == nil else { return }

        personalityTask = Task { @MainActor in
            while !Task.isCancelled {
                let delay = UInt64(Double.random(in: 3.5...7.5) * 1_000_000_000)
                try? await Task.sleep(nanoseconds: delay)
                guard !Task.isCancelled else { return }

                switch Int.random(in: 0...2) {
                case 0:
                    withAnimation { isBlinking = true }
                    try? await Task.sleep(nanoseconds: 180_000_000)
                    withAnimation { isBlinking = false }
                case 1:
                    withAnimation { isWobbling = true }
                    try? await Task.sleep(nanoseconds: 520_000_000)
                    withAnimation { isWobbling = false }
                default:
                    withAnimation { isFallen = true }
                    try? await Task.sleep(nanoseconds: 1_250_000_000)
                    withAnimation { isFallen = false }
                }
            }
        }
    }
}

private struct NeonWinkFace: View {
    @Binding var isBlinking: Bool

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 5) {
                GlowingEye(isBlinking: $isBlinking)
                WinkEye()
            }

            SmileShape()
                .stroke(
                    LinearGradient(
                        colors: [.white, .cyan.opacity(0.95), .pink.opacity(0.95)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 16, height: 7)
                .overlay(alignment: .bottom) {
                    FangShape()
                        .fill(.pink.opacity(0.95))
                        .frame(width: 3, height: 3)
                        .offset(x: 2, y: 1)
                }
        }
        .frame(width: 30, height: 20)
        .shadow(color: .cyan.opacity(0.45), radius: 3)
        .shadow(color: .pink.opacity(0.25), radius: 2)
    }
}

private struct SleepyFace: View {
    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 6) {
                Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: 7, height: 2)
                Capsule()
                    .fill(.white.opacity(0.9))
                    .frame(width: 7, height: 2)
            }

            SmileShape()
                .stroke(.white.opacity(0.9), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                .frame(width: 11, height: 5)

            HStack(spacing: 2) {
                Circle().fill(.purple.opacity(0.8)).frame(width: 2, height: 2)
                Circle().fill(.purple.opacity(0.8)).frame(width: 2, height: 2)
            }
            .offset(y: -1)
        }
        .frame(width: 30, height: 20)
        .shadow(color: .purple.opacity(0.5), radius: 3)
    }
}

private struct PixelBotFace: View {
    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 6) {
                PixelEye(color: .mint)
                PixelEye(color: .orange)
            }

            HStack(spacing: 2) {
                Rectangle().fill(.white).frame(width: 3, height: 2)
                Rectangle().fill(.white).frame(width: 6, height: 2)
                Rectangle().fill(.white).frame(width: 3, height: 2)
            }
        }
        .frame(width: 30, height: 20)
        .shadow(color: .mint.opacity(0.4), radius: 3)
    }
}

private struct StarstruckFace: View {
    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 5) {
                StarShape()
                    .fill(.yellow)
                    .frame(width: 6, height: 6)
                StarShape()
                    .fill(.pink)
                    .frame(width: 6, height: 6)
            }

            SmileShape()
                .stroke(.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 15, height: 7)
        }
        .frame(width: 30, height: 20)
        .shadow(color: .yellow.opacity(0.45), radius: 3)
    }
}

private struct DarthVaderFace: View {
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: 7, y: 5))
                path.addLine(to: CGPoint(x: 10, y: 1))
                path.addLine(to: CGPoint(x: 20, y: 1))
                path.addLine(to: CGPoint(x: 23, y: 5))
                path.addLine(to: CGPoint(x: 26, y: 18))
                path.addLine(to: CGPoint(x: 4, y: 18))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [.black, .gray.opacity(0.45), .black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            HStack(spacing: 7) {
                Rectangle().fill(.red).frame(width: 4, height: 1.5)
                Rectangle().fill(.red).frame(width: 4, height: 1.5)
            }
            .shadow(color: .red, radius: 3)
            .offset(y: -2)

            VStack(spacing: 1) {
                Rectangle().fill(.gray.opacity(0.75)).frame(width: 8, height: 1)
                Rectangle().fill(.gray.opacity(0.45)).frame(width: 6, height: 1)
                Rectangle().fill(.gray.opacity(0.75)).frame(width: 8, height: 1)
            }
            .offset(y: 7)
        }
        .frame(width: 30, height: 20)
        .shadow(color: .red.opacity(0.35), radius: 3)
    }
}

private struct JasonVoorheesFace: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.white, .gray.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 18, height: 18)

            HStack(spacing: 6) {
                Circle().fill(.black).frame(width: 3, height: 2.5)
                Circle().fill(.black).frame(width: 3, height: 2.5)
            }
            .offset(y: -2)

            Rectangle()
                .fill(.red.opacity(0.9))
                .frame(width: 2, height: 8)
                .rotationEffect(.degrees(-35))
                .offset(x: -5, y: 4)

            HStack(spacing: 4) {
                Circle().fill(.black.opacity(0.8)).frame(width: 1.5, height: 1.5)
                Circle().fill(.black.opacity(0.8)).frame(width: 1.5, height: 1.5)
                Circle().fill(.black.opacity(0.8)).frame(width: 1.5, height: 1.5)
            }
            .offset(y: 5)
        }
        .frame(width: 30, height: 20)
        .shadow(color: .red.opacity(0.45), radius: 2)
    }
}

private struct AmongUsFace: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        colors: [.red, .red.opacity(0.65)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 17, height: 16)
                .offset(x: 7, y: -1)

            RoundedRectangle(cornerRadius: 3)
                .fill(.blue.opacity(0.95))
                .frame(width: 10, height: 6)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(.white.opacity(0.65), lineWidth: 1)
                }
                .offset(x: 11, y: -7)

            RoundedRectangle(cornerRadius: 2)
                .fill(.red.opacity(0.9))
                .frame(width: 5, height: 10)
                .offset(x: 2, y: -2)

            HStack(spacing: 4) {
                Rectangle().fill(.red).frame(width: 4, height: 4)
                Rectangle().fill(.red).frame(width: 4, height: 4)
            }
            .offset(x: 9, y: 0)
        }
        .frame(width: 30, height: 20)
        .shadow(color: .red.opacity(0.45), radius: 3)
    }
}

private struct GlowingEye: View {
    @Binding var isBlinking: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(
                    LinearGradient(
                        colors: [.white, .cyan, .blue.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if !isBlinking {
                Circle()
                    .fill(.black.opacity(0.9))
                    .frame(width: 2, height: 2)
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(.white)
                            .frame(width: 0.8, height: 0.8)
                    }
            }
        }
        .frame(width: 5, height: isBlinking ? 1.5 : 4)
        .animation(.easeInOut(duration: 0.1), value: isBlinking)
    }
}

private struct WinkEye: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 3))
            path.addQuadCurve(to: CGPoint(x: 7, y: 2), control: CGPoint(x: 3.5, y: 0))
        }
        .stroke(.pink, style: StrokeStyle(lineWidth: 2, lineCap: .round))
        .frame(width: 7, height: 5)
        .shadow(color: .pink.opacity(0.8), radius: 2)
    }
}

private struct PixelEye: View {
    let color: Color

    var body: some View {
        ZStack {
            Rectangle().fill(color).frame(width: 5, height: 5)
            Rectangle().fill(.black.opacity(0.85)).frame(width: 2, height: 2)
        }
    }
}

private struct SmileShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + 1))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + 1),
            control: CGPoint(x: rect.midX, y: rect.maxY + 2)
        )
        return path
    }
}

private struct FangShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

private struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.42
        var path = Path()

        for index in 0..<10 {
            let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = (Double(index) * .pi / 5) - (.pi / 2)
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

struct MinimalFaceFeatures_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 18) {
            ForEach(BoringFaceStyle.allCases) { style in
                VStack(spacing: 8) {
                    MinimalFaceFeatures(style: style, height: 40, width: 60)
                    Text(style.rawValue)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
