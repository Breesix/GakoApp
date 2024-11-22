//
//  PauseButtonVoice.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import SwiftUI
import DotLottie

struct PauseButtonVoice: View {
    var body: some View {
        VStack{
            DotLottieAnimation(fileName: "recordLottie",
                               config: AnimationConfig(autoplay: true, loop: true))
            .view()
            .scaleEffect(1.4)
            .frame(width: 84, height: 84)
        }
    }
}

#Preview {
    PauseButtonVoice()
}
