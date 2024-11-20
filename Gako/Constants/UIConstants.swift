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
    
    enum MainTabView {
        static let tabBarHeight: CGFloat = 72
        static let tabBarSpacing: CGFloat = 0
        static let tabBarBottomPadding: CGFloat = 5
        static let shadowRadius: CGFloat = 0
        static let shadowOffset: CGFloat = 50
        static let tabBarBackground: Color = .white
        static let shadowColor: Color = .black.opacity(1)
    }
    
    enum ActivityRow {
        static let spacing: CGFloat = 10
        static let deleteButtonSize: CGFloat = 34
        static let cornerRadius: CGFloat = 8
        static let strokeWidth: CGFloat = 0.5
        static let contentPadding: CGFloat = 8
        static let statusPickerSpacing: CGFloat = 8
        static let primaryText: Color = .labelPrimaryBlack
        static let destructiveButton: Color = .buttonDestructiveOnCard
        static let destructiveLabel: Color = .destructiveOnCardLabel
        static let background: Color = .monochrome100
        static let stroke: Color = .noteStroke
    }
    
    enum DailyReport {
        struct Layout {
            static let headerHeight: CGFloat = 58
            static let headerCornerRadius: CGFloat = 16
            static let contentPadding: CGFloat = 16
            static let buttonHeight: CGFloat = 50
            static let buttonCornerRadius: CGFloat = 12
            static let spacing: CGFloat = 12
        }
        
        struct Colors {
            static let headerBackground: Color = .bgSecondary
            static let mainBackground: Color = .bgMain
            static let buttonBackground: Color = .orangeClickAble
            static let buttonText: Color = .labelPrimaryBlack
        }
        
        struct Text {
            static let editButtonTitle = "Edit"
            static let saveButtonTitle = "Simpan"
            static let shareButtonTitle = "Bagikan Dokumentasi"
            static let summaryTitle = "Ringkasan"
        }
    }

    struct SummaryTab {
        enum Spacing {
            static let none: CGFloat = 0
            static let tiny: CGFloat = 8
            static let small: CGFloat = 12
            static let medium: CGFloat = 16
            static let large: CGFloat = 24
            static let bottomPadding: CGFloat = 72
        }
        
        // MARK: - Navigation
        enum Navigation {
            static let documentationTitle = "Dokumentasi"
            static let documentationButtonText = "Dokumentasi"
        }
        
        // MARK: - Alert Messages
        enum AlertMessages {
            static let noStudentsTitle = "Tidak Ada Murid"
            static let noStudentsMessage = "Anda masih belum memiliki Daftar Murid. Tambahkan murid Anda ke dalam Gako melalu menu Murid"
            static let noInternetTitle = "Tidak Ada Koneksi Internet"
            static let noInternetMessage = "Pastikan Anda Terhubung ke internet untuk menggunkan fitur ini"
            static let addStudentButtonText = "Tambahkan Murid"
            static let okButtonText = "OK"
        }
        
        // MARK: - Empty State
        enum EmptyState {
            static let noNotesMessage = "Belum ada catatan di hari ini."
        }
        
        // MARK: - Animation
        enum Animation {
            static let buttonDelay: TimeInterval = 0.3
        }
    }

    enum ProgressCurhat {
        static let padding: CGFloat = 8
        static let cornerRadius: CGFloat = 8
        static let backgroundColor: Color = .cardFieldBG
        static let deleteButtonColor: Color = .red
        static let trashIconName: String = "trash"
        
        // Text Constants
        static let selectStudentAlertTitle = "Pilih Murid"
        static let selectStudentAlertMessage = "Silakan pilih minimal satu murid yang hadir."
        static let cancelDocumentationAlertTitle = "Batalkan Dokumentasi?"
        static let cancelDocumentationAlertMessage = "Semua teks yang baru saja Anda masukkan akan terhapus secara permanen."
        static let addActivityAlertTitle = "Tambah Aktivitas"
        static let addActivityAlertMessage = "Silakan tambah minimal satu aktivitas."
        static let deleteActivityAlertTitle = "Hapus Aktivitas?"
        static let deleteActivityAlertMessage = "Apakah Anda yakin ingin menghapus aktivitas ini?"
        static let cancelDocumentationButtonText = "Batalkan Dokumentasi"
        static let continueDocumentationButtonText = "Lanjut Dokumentasi"
        static let deleteButtonText = "Hapus"
        static let cancelButtonText = "Batal"
        static let okButtonText = "OK"
        static let backButtonText = "Kembali"
        static let saveButtonText = "Simpan"
        static let addActivityText = "Tambah Aktivitas"
        static let editActivityText = "Edit Aktivitas"
        static let addText = "Tambah"
        static let writeActivityPlaceholder = "Tuliskan aktivitas murid..."
        static let guidingQuestion1 = "Apakah aktivitas dijalankan dengan baik?"
        static let guidingQuestion2 = "Apakah Murid mengalami kendala?"
        static let guidingQuestion3 = "Bagaimana Murid Anda menjalankan aktivitasnya?"
        static let currentTitle1 = "Apakah semua Murid hadir?"
        static let currentTitle2 = "Tambahkan aktivitas"
        static let currentTitle3 = "Ceritakan tentang Hari ini"
        static let currentSubtitle1 = "Pilih murid Anda yang hadir untuk mengikuti aktivitas hari ini."
        static let currentSubtitle2 = "Tambahkan rincian aktivitas murid anda hari ini."
        static let currentSubtitle3 = "Rekam cerita Anda terkait kegiatan murid Anda pada hari ini sedetail mungkin."
        static let startStoryText = "Mulai Cerita"
        static let continueText = "Lanjut"
        static let backText = "Kembali"
        static let cancelText = "Batal"
    }

    enum ManageUnsavedActivityViewConstants {
    static let topPadding: CGFloat = 34.5
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 9
    static let cornerRadius: CGFloat = 8
    static let strokeWidth: CGFloat = 0.5
    static let buttonTopPadding: CGFloat = 27
    static let toggleTopPadding: CGFloat = 24
    static let menuHorizontalPadding: CGFloat = 16
    static let menuVerticalPadding: CGFloat = 11
    static let labelPrimaryBlack: Color = .labelPrimaryBlack
    static let labelTertiary: Color = .labelTertiary
    static let cardFieldBG: Color = .cardFieldBG
    static let monochrome50: Color = .monochrome50
    static let statusSheet: Color = .statusSheet

    static let addActivityTitle = "Tambah Aktivitas"
    static let editActivityTitle = "Nama Aktivitas"
    static let placeholderText = "Tuliskan aktivitas murid..."
    static let bulkEditToggleText = "Edit aktivitas ini untuk semua murid"
    static let mandiriText = "Mandiri"
    static let dibimbingText = "Dibimbing"
    static let tidakMelakukanText = "Tidak Melakukan"
    static let backButtonText = "Kembali"
    static let saveButtonText = "Simpan"
    static let alertTitle = "Peringatan"
    static let alertMessage = "Aktivitas tidak boleh kosong"
    }
}
