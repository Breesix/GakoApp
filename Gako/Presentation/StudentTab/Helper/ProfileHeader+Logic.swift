//
//  ProfileHeader+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides utility methods for ProfileHeader
//  Usage: Contains methods for name validation, image processing, and text formatting
//

import Foundation
import UIKit


extension ProfileHeader {
    // MARK: - Image Processing
    func processImageData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    // MARK: - Validation
    func hasValidImage() -> Bool {
        return student.imageData != nil
    }
    
    func isValidName() -> Bool {
        return !student.fullname.isEmpty && !student.nickname.isEmpty
    }
    
    // MARK: - Formatting
    func formattedFullName() -> String {
        return student.fullname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func formattedNickname() -> String {
        return student.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
