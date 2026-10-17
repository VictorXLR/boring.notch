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
