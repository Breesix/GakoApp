//  LoadingView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 31/10/24.
//

import SwiftUI
import DotLottie

struct LoadingView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0.0
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                DotLottieAnimation(fileName: "loading_save",
                                 config: AnimationConfig(autoplay: true, loop: true))
                    .view()
                    .scaleEffect(isAnimating ? 1.5 : 0.8)
                    .opacity(isAnimating ? 1 : 0)
                    .frame(width: 300, height: 300)
            }
        }
        .onChange(of: progress) {
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = progress
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = progress
            }
        }
        .onDisappear {
            withAnimation(.easeOut(duration: 0.3)) {
                isAnimating = false
            }
        }
    }
}

#Preview {
    ScrollView {
        LoadingView(progress: 0.0)
        LoadingView(progress: 0.5)
        LoadingView(progress: 1.0)
    }
}

