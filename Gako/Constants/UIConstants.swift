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
    
    enum ToastNotification {
        static let cancelSymbol: String = "xmark"
        static let bgColor: Color = .black.opacity(0.8)
        static let spacing: CGFloat = 12
        static let minSpacerLength: CGFloat = 10
        static let padding: CGFloat = 16
        static let cornerRadius: CGFloat = 8
        static let verticalOffset: CGFloat = 32
        
        enum Style {
            case error
            case warning
            case success
            case info
            
            var themeColor: Color {
                switch self {
                case .error: return .red
                case .warning: return .orange
                case .info: return .blue
                case .success: return .bgSecondary
                }
            }
            
            var iconFileName: String {
                switch self {
                case .info: return "info.circle.fill"
                case .warning: return "exclamationmark.triangle.fill"
                case .success: return "checkmark.circle.fill"
                case .error: return "xmark.circle.fill"
                }
            }
        }
    }
    
    enum SnapshotPreview {
        static let maxHeightMultiplier: CGFloat = 0.5
        static let bottomSheetCornerRadius: CGFloat = 16
        static let dragIndicatorCornerRadius: CGFloat = 2.5
        static let dragIndicatorWidth: CGFloat = 36
        static let dragIndicatorHeight: CGFloat = 5
        static let dragIndicatorSpacing: CGFloat = 20
        static let buttonSpacing: CGFloat = 20
        static let horizontalPadding: CGFloat = 16
        static let bottomPadding: CGFloat = 32
        static let topPadding: CGFloat = 8
        static let pageIndicatorSpacing: CGFloat = 8
        static let pageIndicatorBottomPadding: CGFloat = 16
        static let pageIndicatorDotSize: CGFloat = 8
        static let overlayColor: Color = .black.opacity(0.5)
        static let headerBackgroundColor: Color = .black.opacity(0.3)
        static let dragIndicatorColor: Color = .gray.opacity(0.3)
        static let bottomSheetColor: Color = .white
        static let whatsAppButtonColor: Color = .green
        static let saveButtonColor: Color = .blue
        static let shareButtonColor: Color = .orange
        static let activeDotColor: Color = .accent
        static let inactiveDotColor: Color = .gray.opacity(0.3)
        static let saveSuccessMessage: String = "Semua halaman berhasil disimpan"
        static let saveErrorMessage: String = "Gagal menyimpan gambar"
        static let shareTitle: String = "Share All"
        static let shareIcon: String = "square.and.arrow.up"
        static let whatsAppTitle: String = "WhatsApp"
        static let whatsAppIcon: String = "square.and.arrow.up"
        static let saveTitle: String = "Save All"
        static let saveIcon: String = "square.and.arrow.down"
        static let xmarkSymbol: String = "xmark"
        static let durationToast: CGFloat = 2
    }
    
    enum SaveLoadingView {
        static let totalProgress: CGFloat = 1.0
        static let shadowRadius: CGFloat = 10
        static let imageSize: CGFloat = 200
        static let progressBarWidth: CGFloat = 200
        static let containerCornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 40
        static let verticalSpacing: CGFloat = 20
        static let animationDuration: CGFloat = 0.3
        static let overlayColor: Color = .white.opacity(0.9)
        static let containerColor: Color = .white
        static let progressBarTint: Color = .orangeClickAble
        static let titleColor: Color = .labelPrimaryBlack
        static let subtitleColor: Color = .gray
        static let expressionsImage: String = "Expressions"
        static let title: String = "Menyimpan Dokumentasi..."
        static let subtitle: String = "Mohon tunggu sebentar"
    }
}
