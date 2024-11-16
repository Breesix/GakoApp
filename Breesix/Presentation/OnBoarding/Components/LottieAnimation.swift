//
//  LottieAnimation.swift
//  Breesix
//
//  Created by Rangga Biner on 16/11/24.
//

import SwiftUI
import DotLottie

struct LottieAnimation: View {
    let lottieFile: String
    
    @State private var isLottieLoaded = false
    
    var body: some View {
        Group {
            if isLottieLoaded {
                DotLottieAnimation(fileName: lottieFile,
                                 config: AnimationConfig(
                                    autoplay: true,
                                    loop: true
                                 ))
                .view()
                .scaleEffect(1.2)
            } else {
                ProgressView()
                    .onAppear {
                        checkLottieFile()
                    }
            }
        }
    }
    
    private func checkLottieFile() {
        let extensions = ["lottie", "json"]
        for ext in extensions {
            if Bundle.main.path(forResource: lottieFile, ofType: ext) != nil {
                isLottieLoaded = true
                return
            }
        }
    }
}
