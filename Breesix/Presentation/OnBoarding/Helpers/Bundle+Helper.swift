//
//  Bundle+Helper.swift
//  Gako
//
//  Created by Rangga Biner on 17/11/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: A helper for Bundle to provide additional functionality for file operations
//

import Foundation

extension Bundle {
    func hasLottieFile(named fileName: String) -> Bool {
        UIConstants.LottieAnimation.supportedExtensions.contains { ext in
            path(forResource: fileName, ofType: ext) != nil
        }
    }
}

