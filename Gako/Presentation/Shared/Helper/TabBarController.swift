//
//  TabBarController.swift
//  Gako
//
//  Created by Rangga Biner on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Helper for tab bar
//  Usage: use this helper for tab bar in my tab view
//

import Foundation

enum TabbedItems: Int, CaseIterable {
    case home = 0
    case student
    
    var title: String {
        switch self {
        case .home:
            return "Dokumentasi"
        case .student:
            return "Murid"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "book.fill"
        case .student:
            return "person.3.fill"
        }
    }
    
    var imageBackground: String {
        switch self {
        case .home:
            return "ringkasan-active"
        case .student:
            return "murid-active"
        }
    }
    
    var negativeImage: String {
        switch self {
        case .home:
            return "ringkasan-inactive"
        case .student:
            return "murid-inactive"
        }
    }
}

class TabBarController: ObservableObject {
    static let shared = TabBarController()
    @Published var isHidden = false
    private var hideCount = 0
    
    func incrementHide() {
        hideCount += 1
        updateHiddenState()
    }
    
    func decrementHide() {
        hideCount -= 1
        updateHiddenState()
    }
    
    private func updateHiddenState() {
        isHidden = hideCount > 0
    }
}
