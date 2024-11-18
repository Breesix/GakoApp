//
//  UIConstants.swift
//  Gako
//
//  Created by Rangga Biner on 16/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A UIConstants that use for UI needs
//  Usage: Use this enum to fill the Value
//

import Foundation
import SwiftUI

enum UIConstants {
    enum PageIndicator {
        static let dotSize: CGFloat = 12
        static let inactiveDotOpacity: Double = 0.6
        static let defaultSpacing: CGFloat = 8
        static let activeColor: Color = .green600
        static let inactiveColor: Color = .monochrome100
    }
    
    enum LottieAnimation {
        static let scaleEffect: CGFloat = 1
        static let supportedExtensions = ["lottie", "json"]
    }
    
    enum OnboardingButtonText {
        static let previous = "Sebelumnya"
        static let next = "Lanjut"
        static let done = "Mengerti"
        static let buttonPadding: CGFloat = 14
        static let buttonSpacing: CGFloat = 16
        static let defaultPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let initialButtonWidth: CGFloat = UIScreen.main.bounds.width/2
        static let nextColor: Color = .buttonPrimaryOnBg
        static let previousColor: Color = .white
    }
    
    enum OnboardingSection {
        static let primaryText: Color = .labelPrimaryBlack
        static let secondaryText: Color = .labelSecondaryBlack
        static let defaultSpacing: CGFloat = 35
        static let textSpacing: CGFloat = 12
    }
    
    enum OnboardingView {
        static let defaultSpacing: CGFloat = 32
        static let sectionPadding: CGFloat = 16
        static let safeArea: CGFloat = 16
    }
    
    enum AddItemButton {
        static let primaryText: Color = .buttonPrimaryLabel
        static let symbol: String = "plus.app.fill"
        static let spacing: CGFloat = 4
        static let verticalPadding: CGFloat = 7
        static let horizontalPadding: CGFloat = 14
        static let cornerRadius: CGFloat = 8
    }
    
    enum CustomNavigation {
        static let bgColor: Color = .bgSecondary
        static let titleColor: Color = .white
        static let cornerRadius: CGFloat = 16
        static let padding: CGFloat = 16
        static let height: CGFloat = 58
    }
    
    enum EmptyState {
        static let textColor: Color = .labelPrimaryBlack.opacity(0.5)
        static let image: String = "emptyStateLogo"
        static let width: CGFloat = 98
        static let defaultSpacing: CGFloat = 12
    }
    
    enum StatusPicker {
        static let symbol: String = "chevron.up.chevron.down"
        static let textPrimary: Color = .labelPrimaryBlack
        static let stroke: Color = .monochrome900
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 7
        static let cornerRadius: CGFloat = 8
        static let borderWidth: CGFloat = 1
    }
}
