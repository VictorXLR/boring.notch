//
//  EmptyState.swift
//
// Created by Harsh Vardhan  Goswami  on  04/08/24.
//

import SwiftUI

struct EmptyStateView: View {
    var message: String
    @State private var isVisible = true
    @State private var isBlinking = false

    private static let blinkInterval: UInt64 = 3_000_000_000
    private static let blinkDuration: UInt64 = 120_000_000
    
    var body: some View {
        HStack {
            MinimalFaceFeatures(
                height: 70,
                width: 80,
                isBlinking: isBlinking
            )
            Text(message)
                .font(.system(size:14))
                .foregroundColor(.gray)
        }
        .transition(.blurReplace.animation(.spring(.bouncy(duration: 0.3)))) // Smooth animation
        .task {
            await blinkFace()
        }
    }

    private func blinkFace() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: Self.blinkInterval)
            guard !Task.isCancelled else { return }

            withAnimation(.easeInOut(duration: 0.1)) { isBlinking = true }
            try? await Task.sleep(nanoseconds: Self.blinkDuration)
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.1)) { isBlinking = false }
        }
    }
}

#Preview {
    EmptyStateView(message: "Play some music babies")
}
