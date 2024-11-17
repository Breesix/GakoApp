//
//  LottieAnimation.swift
//  Gako
//
//  Created by Rangga Biner on 16/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component that displays Lottie animations
//  Usage: Use this component to show lottie animation
//

import SwiftUI
import DotLottie

struct LottieAnimation: View {
    let lottieFile: String
    var scaleEffect: CGFloat = UIConstants.LottieAnimation.scaleEffect
    
    @State var isLottieLoaded = false
    
    var body: some View {
        Group {
            if isLottieLoaded {
                DotLottieAnimation(
                    fileName: lottieFile,
                    config: AnimationConfig(autoplay: true, loop: true)
                )
                .view()
                .scaleEffect(scaleEffect)
            } else {
                ProgressView()
                    .onAppear {
                        checkLottieFile()
                }
            }
        }
    }
}

#Preview {
    LottieAnimation(lottieFile: "inputDokumen")
}
