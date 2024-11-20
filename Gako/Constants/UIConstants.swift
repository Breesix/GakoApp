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
    
    enum SummaryTab {
        struct Layout {
            static let cardSpacing: CGFloat = 12
            static let contentPadding: CGFloat = 16
            static let bottomPadding: CGFloat = 72
            static let dateSliderPadding: CGFloat = 12
        }
        
        struct Colors {
            static let background: Color = .bgMain
            static let accent: Color = .accent
        }
        
        struct Text {
            static let navigationTitle = "Dokumentasi"
            static let emptyStateMessage = "Belum ada catatan di hari ini."
            static let noStudentsTitle = "Tidak Ada Murid"
            static let noStudentsMessage = "Anda masih belum memiliki Daftar Murid. Tambahkan murid Anda ke dalam Gako melalu menu Murid"
            static let addStudentButton = "Tambahkan Murid"
            static let noInternetTitle = "Tidak Ada Koneksi Internet"
            static let noInternetMessage = "Pastikan Anda Terhubung ke internet untuk menggunkan fitur ini"
        }
    }
        
        enum StudentTabView {
            static let gridSpacing: CGFloat = 16
            static let searchBarVerticalPadding: CGFloat = 12
            static let searchBarHorizontalPadding: CGFloat = 16
            static let contentHorizontalPadding: CGFloat = 16
            static let backgroundColor: Color = .bgMain
            static let emptyStateMessageNoStudent: String = "Belum ada murid yang terdaftar."
            static let emptyStateMessageNoSearch: String = "Tidak ada murid yang sesuai dengan pencarian."
            static let navigationTitle: String = "Murid"
            static let navigationButtonText: String = "Murid"
            
            
        }
        enum StudentDetailView {
            static let headerHeight: CGFloat = 58
            static let headerPadding: CGFloat = 14
            static let headerSpacing: CGFloat = 16
            static let contentPadding: EdgeInsets = .init(top: 0, leading: 16, bottom: 12, trailing: 16)
            static let monthSectionPadding: EdgeInsets = .init(top: 12, leading: 16, bottom: 12, trailing: 16)
            static let monthButtonSpacing: CGFloat = 8
            static let cornerRadius: CGFloat = 16
            static let saveButtonHeight: CGFloat = 50
            static let saveButtonCornerRadius: CGFloat = 12
            static let backIcon = "chevron.left"
            static let monthPreviousIcon = "chevron.left"
            static let monthNextIcon = "chevron.right"
            static let editDocumentText = "Edit Dokumen"
            static let cancelText = "Batal"
            static let saveText = "Simpan"
            static let emptyStateMessage = "Belum ada aktivitas yang tercatat."
            static let emptyActivityMessage = "Aktivitas tidak boleh kosong"
            static let emptyNoteMessage = "Catatan tidak boleh kosong"
            static let saveSuccessMessage = "Perubahan berhasil disimpan"
            static let noActivityTitle = "No Activity"
            static let noActivityMessage = "There are no activities recorded for the selected date."
            static let warningTitle = "Peringatan"
            static let cancelConfirmationText = "Apakah Anda yakin ingin membatalkan perubahan?"
            static let monthFormat = "MMMM yyyy"
            static let dateFormat = "dd MMM yyyy"
            static let localeIdentifier = "id_ID"
            static let backgroundColor = Color.bgMain
            static let headerBackgroundColor = Color(.bgSecondary)
            static let headerTextColor = Color.white
            static let monthTextColor = Color.labelPrimaryBlack
            static let monthButtonColor = Color.buttonLinkOnSheet
            static let monthButtonDisabledColor = Color.gray
            static let saveButtonTextColor = Color.labelPrimaryBlack
            static let saveButtonBackgroundColor = Color(.orangeClickAble)
        }
        
        enum MonthList {
            static let headerHeight: CGFloat = 58
            static let headerPadding: CGFloat = 14
            static let contentPadding: EdgeInsets = .init(top: 12, leading: 16, bottom: 0, trailing: 16)
            static let spacing: CGFloat = 12
            static let cornerRadius: CGFloat = 16
            static let monthCardCornerRadius: CGFloat = 12
            static let yearPickerButtonCornerRadius: CGFloat = 8
            static let yearPickerButtonPadding: EdgeInsets = .init(top: 7, leading: 14, bottom: 7, trailing: 14)
            static let monthNavigationSpacing: CGFloat = 8
            static let dividerPadding: CGFloat = 12
            static let pickerWidth: CGFloat = 100
            static let backIcon = "chevron.left"
            static let nextIcon = "chevron.right"
            static let documentIcon = "document.fill"
            static let monthNavigationIcon = "chevron.right"
            static let backText = "Murid"
            static let editProfileText = "Edit Profil"
            static let documentationText = "Lihat Dokumentasi"
            static let selectYearText = "Pilih Tahun"
            static let backgroundColor = Color.bgMain
            static let headerBackgroundColor = Color(.bgSecondary)
            static let headerTextColor = Color.white
            static let documentationTextColor = Color.labelPrimaryBlack
            static let monthNavigationColor = Color.buttonLinkOnSheet
            static let monthNavigationDisabledColor = Color.gray
            static let yearPickerButtonBackground = Color.buttonLinkOnSheet
            static let yearPickerButtonText = Color.buttonPrimaryLabel
            static let monthCardBackground = Color.white
            static let monthCardText = Color.labelPrimaryBlack
            static let yearFormat = "yyyy"
            static let monthFormat = "MMMM"
            static let localeIdentifier = "id_ID"
        }
        
        enum ManageNote {
            static let titleColor = Color.labelPrimaryBlack
            static let textFieldBackground = Color.cardFieldBG
            static let placeholderColor = Color.labelDisabled
            static let textColor = Color.labelPrimaryBlack
            static let borderColor = Color.monochrome50
            static let spacing: CGFloat = 8
            static let topPadding: CGFloat = 34.5
            static let horizontalPadding: CGFloat = 16
            static let toolbarTopPadding: CGFloat = 27
            static let cornerRadius: CGFloat = 8
            static let borderWidth: CGFloat = 1
            static let textEditorHeight: CGFloat = 170
            static let textEditorHorizontalPadding: CGFloat = 8
            static let placeholderPadding = EdgeInsets(top: 9, leading: 11, bottom: 9, trailing: 11)
            static let addNoteTitle = "Tambah Catatan"
            static let editNoteTitle = "Edit Catatan"
            static let placeholderText = "Tuliskan catatan untuk murid..."
            static let backButtonText = "Kembali"
            static let saveButtonText = "Simpan"
            static let alertTitle = "Peringatan"
            static let alertMessage = "Catatan tidak boleh kosong"
            static let okButtonText = "OK"
            static let backIcon = "chevron.left"
        }
        
        enum ManageActivity {
            // Colors
            static let titleColor = Color.labelPrimaryBlack
            static let placeholderColor = Color.labelTertiary
            static let textColor = Color.labelPrimaryBlack
            static let textFieldBackground = Color.cardFieldBG
            static let borderColor = Color.monochrome50
            static let statusMenuBackground = Color.statusSheet
            
            // Layout
            static let spacing: CGFloat = 8
            static let innerSpacing: CGFloat = 12
            static let statusMenuSpacing: CGFloat = 9
            static let topPadding: CGFloat = 34.5
            static let horizontalPadding: CGFloat = 16
            static let toolbarTopPadding: CGFloat = 27
            static let cornerRadius: CGFloat = 8
            static let borderWidth: CGFloat = 0.5
            static let textFieldPadding = EdgeInsets(top: 9, leading: 11, bottom: 9, trailing: 11)
            static let statusMenuPadding = EdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16)
            
            // Text
            static let addActivityTitle = "Tambah Aktivitas"
            static let editActivityTitle = "Edit Aktivitas"
            static let placeholderText = "Tuliskan aktivitas murid..."
            static let backButtonText = "Kembali"
            static let saveButtonText = "Simpan"
            static let alertTitle = "Peringatan"
            static let alertMessage = "Aktivitas tidak boleh kosong"
            static let okButtonText = "OK"
            
            // Status Menu
            static let mandiriText = "Mandiri"
            static let dibimbingText = "Dibimbing"
            static let tidakMelakukanText = "Tidak Melakukan"
            
            // Icons
            static let backIcon = "chevron.left"
            static let statusMenuIcon = "chevron.up.chevron.down"
        }
        
        enum Calendar {
            // Colors
            static let buttonBackground = Color.buttonLinkOnSheet
            static let iconColor = Color.white
            
            // Layout
            static let buttonSize: CGFloat = 36
            static let iconSize: CGFloat = 21
            static let toolbarTopPadding: CGFloat = 14
            static let toolbarHorizontalPadding: CGFloat = 12
            static let contentPadding: CGFloat = 16
            
            // Text
            static let datePickerTitle = "Tanggal"
            static let headerTitle = "Pilih Tanggal"
            static let localeIdentifier = "id_ID"
            
            // Icons
            static let calendarIcon = "calendar"
            static let closeIcon = "xmark"
        }
        
        enum SearchBar {
            // Colors
            static let textColor = Color.buttonPrimaryLabel
            static let placeholderColor = Color.labelSecondaryBlack
            static let backgroundColor = Color.fillTertiary
            static let iconColor = Color.labelSecondaryBlack
            static let recordingIconColor = Color.red
            
            // Layout
            static let cornerRadius: CGFloat = 10
            static let iconPadding: CGFloat = 8
            static let textPadding: CGFloat = 33
            static let verticalPadding: CGFloat = 7
            
            // Text
            static let placeholder = "Search"
            
            // Icons
            static let searchIcon = "magnifyingglass"
            static let micIcon = "mic.fill"
            static let micStopIcon = "mic.fill.badge.xmark"
            static let clearIcon = "multiply.circle.fill"
        }
        
    enum DailyReportStudent {
            // Colors
            static let titleColor = Color.labelPrimaryBlack
            static let buttonBackground = Color.buttonOncard
            static let buttonTextColor = Color.buttonPrimaryLabel
            static let dividerColor = Color.tabbarInactiveLabel
            static let cardBackground = Color.white
            static let emptyTextColor = Color.labelSecondaryBlack
            
            // Layout
            static let cardCornerRadius: CGFloat = 20
            static let buttonSize: CGFloat = 36
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 12
            static let bottomPadding: CGFloat = 16
            static let spacing: CGFloat = 12
            static let dividerHeight: CGFloat = 1
            static let dividerVerticalPadding: CGFloat = 8
            static let dividerTopPadding: CGFloat = 4
            
            // Icons
            static let shareIcon = "square.and.arrow.up"
            
            // Text
            static let alertTitle = "Peringatan"
            static let emptyAlertMessage = "Tidak ada catatan dan aktivitas yang bisa dibagikan"
            static let okButtonText = "OK"
        }
        
        enum DayEdit {
            // Colors
            static let titleColor = Color.labelPrimaryBlack
            static let textColor = Color.labelPrimaryBlack
            static let backgroundColor = Color.white
            static let textFieldBackground = Color.cardFieldBG
            static let emptyTextColor = Color.labelSecondaryBlack
            static let buttonBackground = Color.buttonOncard
            static let buttonTextColor = Color.buttonPrimaryLabel
            static let dividerColor = Color.tabbarInactiveLabel
            
            // Layout
            static let cardCornerRadius: CGFloat = 20
            static let textFieldCornerRadius: CGFloat = 8
            static let spacing: CGFloat = 12
            static let innerSpacing: CGFloat = 8
            static let horizontalPadding: CGFloat = 16
            static let verticalPadding: CGFloat = 12
            static let textFieldPadding = EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
            static let buttonPadding = EdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
            static let dividerHeight: CGFloat = 1
            static let dividerVerticalPadding: CGFloat = 8
            static let trashIconSize: CGFloat = 34
            
            // Text
            static let activitySectionTitle = "AKTIVITAS"
            static let notesSectionTitle = "CATATAN"
            static let activityPrefix = "Aktivitas"
            static let emptyActivityText = "Tidak ada aktivitas untuk tanggal ini"
            static let emptyNotesText = "Tidak ada catatan untuk tanggal ini"
            static let addButtonText = "Tambah"
            
            // Icons
            static let addIcon = "plus.app.fill"
            static let trashIcon = "custom.trash.circle.fill"
        }
        
        enum Edit {
            // Colors
            static let titleColor = Color.labelPrimaryBlack
            static let textColor = Color.labelPrimaryBlack
            static let backgroundColor = Color.monochrome100
            static let strokeColor = Color.noteStroke
            static let deleteButtonBackground = Color.buttonDestructiveOnCard
            static let deleteIconColor = Color.destructiveOnCardLabel
            static let emptyTextColor = Color.labelSecondaryBlack
            
            // Layout
            static let spacing: CGFloat = 12
            static let innerSpacing: CGFloat = 8
            static let deleteButtonSize: CGFloat = 34
            static let cornerRadius: CGFloat = 8
            static let strokeWidth: CGFloat = 0.5
            static let titleBottomPadding: CGFloat = 16
            static let rowBottomPadding: CGFloat = 16
            static let emptyStateBottomPadding: CGFloat = 12
            static let sectionTitleBottomPadding: CGFloat = 4
            
            // Text
            static let activitySectionTitle = "AKTIVITAS"
            static let notesSectionTitle = "CATATAN"
            static let activityPrefix = "Aktivitas"
            static let emptyActivityText = "Tidak ada aktivitas untuk tanggal ini"
            static let emptyNotesText = "Tidak ada catatan untuk tanggal ini"
            static let addButtonText = "Tambah"
            static let deleteAlertTitle = "Hapus Catatan"
            static let deleteActivityAlertTitle = "Konfirmasi Hapus"
            static let deleteAlertMessage = "Apakah Anda yakin ingin menghapus catatan ini?"
            static let deleteActivityAlertMessage = "Apakah kamu yakin ingin menghapus catatan ini?"
            static let cancelButtonText = "Batal"
            static let deleteButtonText = "Hapus"
            
            // Icons
            static let trashIcon = "trash.fill"
            
            static let textFieldPadding: CGFloat = 8
            static let textFieldCornerRadius: CGFloat = 8
            static let textFieldStrokeWidth: CGFloat = 0.5
            static let textFieldBackground = Color.monochrome100
            static let textFieldStrokeColor = Color.noteStroke
            static let textFieldTextColor = Color.labelPrimaryBlack
        }
        enum Activity {
            // Colors
            static let titleColor = Color.labelPrimaryBlack
            static let emptyTextColor = Color.labelSecondaryBlack
            
            // Layout
            static let sectionSpacing: CGFloat = 16
            static let rowBottomPadding: CGFloat = 8
            static let statusPickerSpacing: CGFloat = 8
            
            // Text
            static let sectionTitle = "AKTIVITAS"
            static let emptyStateText = "Tidak ada aktivitas untuk tanggal ini"
            
            enum Analytics {
                static let screenActivityList = "activity_list"
                static let eventStatusChanged = "Activity Status Changed"
                static let eventDeleteAttempted = "Activity Delete Attempted"
                static let eventDeleted = "Activity Deleted"
            }
        }
        
        enum MonthlyEdit {
            // Colors
            static let backgroundColor = Color.white
            static let titleColor = Color.labelPrimaryBlack
            static let dividerColor = Color.tabbarInactiveLabel
            
            // Layout
            static let cardCornerRadius: CGFloat = 20
            static let spacing: CGFloat = 12
            static let horizontalPadding: CGFloat = 16
            static let topPadding: CGFloat = 19
            static let bottomPadding: CGFloat = 16
            static let titleBottomPadding: CGFloat = 7
            static let dividerHeight: CGFloat = 1
            static let dividerVerticalPadding: CGFloat = 4
            static let dividerBottomPadding: CGFloat = 8
        }
        
        enum Note {
            // Colors
            static let titleColor = Color.labelPrimaryBlack
            static let emptyTextColor = Color.secondary
            static let textColor = Color.labelPrimaryBlack
            
            // Layout
            static let sectionSpacing: CGFloat = 12
            static let titleBottomPadding: CGFloat = 4
            static let bulletPointSpacing: CGFloat = 8
            
            // Text
            static let sectionTitle = "CATATAN"
            static let emptyStateText = "Tidak ada catatan untuk tanggal ini"
            static let bulletPoint = "•"
            
            // Delete Button
            static let deleteButtonSize: CGFloat = 34
            static let deleteButtonBackground = Color.buttonDestructiveOnCard
            static let deleteIconColor = Color.destructiveOnCardLabel
            static let trashIcon = "trash.fill"
            
            // Alert
            static let deleteAlertTitle = "Hapus Catatan"
            static let deleteAlertMessage = "Apakah Anda yakin ingin menghapus catatan ini?"
            static let cancelButtonText = "Batal"
            static let deleteButtonText = "Hapus"
        }
        
        enum Profile {
            // Colors
            static let textColor = Color.labelPrimaryBlack
            static let placeholderImageColor = Color.bgSecondary
            static let borderColor = Color.white
            
            // Layout
            static let headerSpacing: CGFloat = 16
            static let headerImageSize: CGFloat = 64
            static let cardImageSize: CGFloat = 104
            static let cardSpacing: CGFloat = 8
            static let spacing: CGFloat = 0
            static let borderWidth: CGFloat = 5
            static let borderInset: CGFloat = 2.5
            static let nicknameHeight: CGFloat = 21
            static let cardCornerRadius: CGFloat = 32
            static let nicknamePaddingVertical: CGFloat = 6
            static let minHeight: CGFloat = 21
            static let maxHeight: CGFloat = 21
            static let horizontalPadding: CGFloat = 0
            static let verticalPadding: CGFloat = 6
            
            // Icons
            static let placeholderIcon = "person.circle.fill"
            static let deleteIcon = "trash"
            
            // Text
            static let deleteButtonText = "Delete"
        }
        
        enum Share {
            // Layout
            static let verticalPadding: CGFloat = 12
            static let cornerRadius: CGFloat = 10
            
            // Font
            static let iconFont = Font.title2
            static let titleFont = Font.caption
            
            // Color
            static let textColor = Color.white
        }
        
        enum EditActivity {
            // Section
            static let sectionTitle = "AKTIVITAS"
            static let emptyStateText = "Tidak ada aktivitas untuk tanggal ini"
            static let addButtonText = "Tambah"
            static let bottomPadding: CGFloat = 16
            static let rowBottomPadding: CGFloat = 12
            
            // Row
            static let deleteButtonSize: CGFloat = 34
            static let rowSpacing: CGFloat = 10
            static let activityPadding: CGFloat = 8
            static let cornerRadius: CGFloat = 8
            static let strokeWidth: CGFloat = 0.5
            static let statusPickerSpacing: CGFloat = 8
            
            // Alert
            static let deleteAlertTitle = "Konfirmasi Hapus"
            static let deleteAlertMessage = "Apakah kamu yakin ingin menghapus catatan ini?"
            static let deleteButtonText = "Hapus"
            static let cancelButtonText = "Cancel"
        }
        
        enum EditNote {
            // Section
            static let sectionTitle = "CATATAN"
            static let emptyStateText = "Tidak ada catatan untuk tanggal ini"
            static let addButtonText = "Tambah"
            static let sectionSpacing: CGFloat = 12
            static let titleBottomPadding: CGFloat = 4
            
            // Row
            static let rowSpacing: CGFloat = 8
            static let notePadding: CGFloat = 8
            static let cornerRadius: CGFloat = 8
            static let strokeWidth: CGFloat = 0.5
            static let deleteButtonSize: CGFloat = 34
            
            // Alert
            static let deleteAlertTitle = "Hapus Catatan"
            static let deleteAlertMessage = "Apakah Anda yakin ingin menghapus catatan ini?"
            static let deleteButtonText = "Hapus"
            static let cancelButtonText = "Batal"
        }
        enum DailyReportTemplate {
            static let a4Width: CGFloat = 595.276
            static let a4Height: CGFloat = 841.89
            static let logoWidth: CGFloat = 100
            static let studentImageSize: CGFloat = 64
            static let watermarkSize: CGFloat = 200
            static let studentInfoHeight: CGFloat = 90
            static let borderWidth: CGFloat = 1
            static let borderInset: CGFloat = 0.5
            static let cornerRadius: CGFloat = 12
            static let spacing: CGFloat = 8
            static let headerSpacing: CGFloat = 16
            
            // Section Titles
            static let reportTitle = "Laporan Harian Murid"
            static let summaryTitle = "Ringkasan:"
            static let activityTitle = "Aktivitas"
            static let statusTitle = "Keterangan"
            static let notesTitle = "Catatan:"
            
            // Empty States
            static let noSummaryText = "Tidak ada ringkasan untuk hari ini"
            
            // Footer
            static let sharedText = "Dibagikan melalui Aplikasi GAKO"
            static let pageText = "Halaman"
            static let fromText = "dari"
            
            // Images
            static let logoImage = "gako_logotype"
            static let watermarkImage = "gako_wm"
            static let defaultProfileImage = "person.circle.fill"
            
            // Colors
            static let headerTextColor: Color = .labelPrimary
            static let primaryTextColor: Color = .labelPrimaryBlack
            static let secondaryTextColor: Color = .secondary
            static let borderColor: Color = .green300
            static let backgroundColor: Color = .white
            static let activityHeaderColor: Color = .green300
            static let footerTextColor: Color = .gray
            static let watermarkColor: Color = .gray.opacity(0.1)
            static let profileImageColor: Color = .bgSecondary
        }
    }
