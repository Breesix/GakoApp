//
//  LottieAnimation+Helper.swift
//  Gako
//
//  Created by Rangga Biner on 17/11/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: A helper for LottieAnimation to provide additional functionality for Check Lottie File
//

import Foundation

extension LottieAnimation {
    func checkLottieFile() {
        isLottieLoaded = Bundle.main.hasLottieFile(named: lottieFile)
    }
}

