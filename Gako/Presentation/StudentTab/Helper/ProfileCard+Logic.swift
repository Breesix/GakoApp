//
//  ProfileCard+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import Foundation
import UIKit

extension ProfileCard {
    // MARK: - Delete Handling
    func handleDelete() {
        showDeleteAlert = true
    }
    
    func confirmDelete() {
        onDelete()
    }
    
    // MARK: - Image Processing
    func processImageData(_ data: Data) -> UIImage? {
        return UIImage(data: data)
    }
    
    // MARK: - Validation
    func hasValidImage() -> Bool {
        return student.imageData != nil
    }
    
    func isValidProfile() -> Bool {
        return !student.nickname.isEmpty && hasValidImage()
    }
    
    // MARK: - Formatting
    func formattedNickname() -> String {
        return student.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
