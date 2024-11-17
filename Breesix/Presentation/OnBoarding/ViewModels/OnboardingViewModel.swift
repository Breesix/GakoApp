//
//  OnboardingViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 17/11/24.
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    var isLastPage: Bool {
        currentPage == onboardingItems.count - 1
    }
    
    var showPreviousButton: Bool {
        currentPage > 0
    }
    
    func handleNextButton() {
        if isLastPage {
            isOnboarding = false
        } else {
            currentPage += 1
        }
    }
    
    func handlePreviousButton() {
        currentPage = max(0, currentPage - 1)
    }
}

