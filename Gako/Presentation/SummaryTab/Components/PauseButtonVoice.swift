//
//  PauseButtonVoice.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Description: A button view for pausing the voice recording in the input view.
//  Usage: Use this view to pause the voice recording in the input view.

import SwiftUI
import DotLottie

struct PauseButtonVoice: View {
    var body: some View {
        VStack{
            DotLottieAnimation(fileName: "recordLottie",
                               config: AnimationConfig(autoplay: true, loop: true))
            .view()
            .scaleEffect(1.4)
            .frame(width: 100, height: 100)
            
        }
    }
}

#Preview {
    PauseButtonVoice()
}
