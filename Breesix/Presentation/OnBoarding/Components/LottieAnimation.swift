//
//  LottieAnimation.swift
//  Breesix
//
//  Created by Rangga Biner on 16/11/24.
//
//  A custom component that displays Lottie animations
//  Usage: Use this component to show lottie animation
//


import SwiftUI
import DotLottie

struct LottieAnimation: View {
    let lottieFile: String
    
    @State private var isLottieLoaded = false
    
    var body: some View {
            if isLottieLoaded {
                DotLottieAnimation(fileName: lottieFile, config: AnimationConfig(autoplay: true, loop: true))
                .view()
                .scaleEffect(UIConstants.LottieAnimation.scaleEffect)
            } else {
                ProgressView()
                    .onAppear {
                        checkLottieFile()
                    }
            }
    }
    
    private func checkLottieFile() {
        let extensions = UIConstants.LottieAnimation.supportedExtensions
        for ext in extensions {
            if Bundle.main.path(forResource: lottieFile, ofType: ext) != nil {
                isLottieLoaded = true
                return
            }
        }
    }
}

#Preview {
    LottieAnimation(lottieFile: "inputDokumen")
}
