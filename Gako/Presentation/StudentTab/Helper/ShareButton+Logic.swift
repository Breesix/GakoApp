//
//  ShareButton+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import Foundation

extension ShareButton {
    // MARK: - Validation
    func isValidTitle() -> Bool {
        return !title.isEmpty
    }
    
    func isValidIcon() -> Bool {
        return !icon.isEmpty
    }
    
    // MARK: - Action Handling
    func handleShare() {
        guard isValidTitle() && isValidIcon() else { return }
        action()
    }
}
