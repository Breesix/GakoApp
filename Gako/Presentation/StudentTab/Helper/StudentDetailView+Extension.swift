//
//  StudentDetailView+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//

import Foundation
import SwiftUI

extension StudentDetailView {
    var headerView: some View {
        ZStack {
            UIConstants.StudentDetailView.headerBackgroundColor
                .cornerRadius(UIConstants.StudentDetailView.cornerRadius,
                              corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea(edges: .top)
            
            HStack(spacing: UIConstants.StudentDetailView.headerSpacing) {
                backButton
                Spacer()
                if !viewModel.isEditingMode {
                    editButton
                }
            }
            .padding(UIConstants.StudentDetailView.headerPadding)
        }
        .frame(height: UIConstants.StudentDetailView.headerHeight)
    }
    
    var contentView: some View {
        VStack(spacing: 0) {
            monthSelectorView
            
            if viewModel.activitiesForSelectedMonth.isEmpty {
                emptyStateView
            } else {
                ScrollViewReader { proxy in
                    scrollContent(proxy: proxy)
                }
            }
            
            if viewModel.isEditingMode {
                saveButton
            }
        }
    }
    
    var monthSelectorView: some View {
        HStack {
            Text(viewModel.formattedMonth)
                .fontWeight(.semibold)
                .foregroundColor(UIConstants.StudentDetailView.monthTextColor)
            
            monthNavigationButtons
            
            Spacer()
            
            calendarButton
        }
        .padding(UIConstants.StudentDetailView.monthSectionPadding)
    }
    
    var monthNavigationButtons: some View {
        HStack(spacing: UIConstants.StudentDetailView.monthButtonSpacing) {
            Button(action: { viewModel.moveMonth(by: -1) }) {
                Image(systemName: UIConstants.StudentDetailView.monthPreviousIcon)
                    .foregroundStyle(UIConstants.StudentDetailView.monthButtonColor)
            }
            
            Button(action: { viewModel.moveMonth(by: 1) }) {
                Image(systemName: UIConstants.StudentDetailView.monthNextIcon)
                    .foregroundStyle(viewModel.isNextMonthDisabled ?
                                     UIConstants.StudentDetailView.monthButtonDisabledColor :
                                        UIConstants.StudentDetailView.monthButtonColor)
            }
            .disabled(viewModel.isNextMonthDisabled)
        }
    }
    
    var calendarButton: some View {
        CalendarButton(
            selectedDate: $viewModel.selectedDate,
            isShowingCalendar: $viewModel.isShowingCalendar
        ) { date in
            viewModel.handleDateSelection(date)
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Spacer()
            EmptyState(message: UIConstants.StudentDetailView.emptyStateMessage)
            Spacer()
        }
    }
    func normalModeCard(for day: Date, items: DayItems) -> some View {
        DailyReportCard(
            activities: items.activities,
            notes: items.notes,
            student: student,
            date: day,
            onAddNote: {
                viewModel.selectedDate = day
                isAddingNewNote = true
            },
            onAddActivity: {
                viewModel.selectedDate = day
                isAddingNewActivity = true
            },
            onDeleteActivity: { activity in
                Task {
                    await viewModel.deleteActivity(activity)
                }
            },
            onEditNote: { noteToEdit = $0 },
            onDeleteNote: { note in
                Task {
                    await viewModel.deleteNote(note)
                }
            },
            onShareTapped: { date in
                viewModel.selectedActivityDate = date
                viewModel.generateSnapshot(for: date)
            },
            onUpdateActivityStatus: { activity, status in
                Task {
                    await viewModel.onUpdateActivityStatus(activity, status)
                }
            }
        )
        .padding(UIConstants.StudentDetailView.contentPadding)
    }
    
    func editModeCard(for day: Date, items: DayItems) -> some View {
        MonthlyEditCard(
            date: day,
            activities: items.activities,
            notes: items.notes,
            student: student,
            selectedStudent: .constant(nil),
            isAddingNewActivity: $isAddingNewActivity,
            editedActivities: $viewModel.editedActivities,
            editedNotes: $viewModel.editedNotes,
            onDeleteActivity: { activity in
                Task {
                    await viewModel.deleteActivity(activity)
                }
            },
            onDeleteNote: { note in
                Task {
                    await viewModel.deleteNote(note)
                }
            },
            onActivityUpdate: { activity in
                activityToEdit = activity
            },
            onAddActivity: {
                viewModel.selectedDate = day
                isAddingNewActivity = true
            },
            onUpdateActivityStatus: { activity, status in
                Task {
                    await viewModel.onUpdateActivityStatus(activity, status)
                }
            },
            onEditNote: { note in
                noteToEdit = note
            },
            onAddNote: { _ in
                viewModel.selectedDate = day
                isAddingNewNote = true
            }
        )
        .padding(UIConstants.StudentDetailView.contentPadding)
    }
    
    // MARK: - Helper Methods
    func sortedDates() -> [Date] {
        Array(viewModel.activitiesForSelectedMonth.keys).sorted()
    }
    
    func scrollContent(proxy: ScrollViewProxy) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(sortedDates(), id: \.self) { day in
                    if let dayItems = viewModel.activitiesForSelectedMonth[day] {
                        if viewModel.isEditingMode {
                            editModeCard(for: day, items: dayItems)
                        } else {
                            normalModeCard(for: day, items: dayItems)
                        }
                    }
                }
            }
            .task {
                viewModel.setupInitialScroll(proxy: proxy)
            }
            .onChange(of: viewModel.selectedDate) {
                viewModel.handleDateChange(proxy: proxy)
            }
        }
    }
    var saveButton: some View {
        Button {
            Task {
                await viewModel.saveChanges()
            }
        } label: {
            Text(UIConstants.StudentDetailView.saveText)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(UIConstants.StudentDetailView.saveButtonTextColor)
                .frame(maxWidth: .infinity)
                .frame(height: UIConstants.StudentDetailView.saveButtonHeight)
                .background(UIConstants.StudentDetailView.saveButtonBackgroundColor)
                .cornerRadius(UIConstants.StudentDetailView.saveButtonCornerRadius)
        }
        .padding(UIConstants.StudentDetailView.contentPadding)
        .background(UIConstants.StudentDetailView.backgroundColor)
    }
    
    var snapshotPreviewView: some View {
        SnapshotPreview(
            images: viewModel.allPageSnapshots,
            currentPageIndex: $viewModel.currentPageIndex,
            showSnapshotPreview: $viewModel.showSnapshotPreview,
            toast: $viewModel.toast,
            shareToWhatsApp: viewModel.shareToWhatsApp,
            showShareSheet: showShareSheet
        )
    }
    
    
    var backButton: some View {
        Button(action: {
            isTabBarHidden = false
            !viewModel.isEditingMode ? presentationMode.wrappedValue.dismiss() : (viewModel.showingCancelAlert = true)
        }) {
            HStack(spacing: 3) {
                Image(systemName: UIConstants.StudentDetailView.backIcon)
                    .foregroundColor(UIConstants.StudentDetailView.headerTextColor)
                    .fontWeight(.semibold)
                Text(!viewModel.isEditingMode ? student.nickname : UIConstants.StudentDetailView.cancelText)
                    .foregroundStyle(UIConstants.StudentDetailView.headerTextColor)
                    .font(.body)
                    .fontWeight(.regular)
            }
        }
    }
    
    var editButton: some View {
        Button {
            viewModel.isEditingMode = true
        } label: {
            Text(UIConstants.StudentDetailView.editDocumentText)
                .foregroundStyle(UIConstants.StudentDetailView.headerTextColor)
                .font(.body)
                .fontWeight(.regular)
        }
    }
    
    var alerts: some View {
        self
            .toastView(toast: $viewModel.toast)
            .alert(UIConstants.StudentDetailView.noActivityTitle,
                   isPresented: $viewModel.noActivityAlertPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(UIConstants.StudentDetailView.noActivityMessage)
            }
            .alert(UIConstants.StudentDetailView.warningTitle,
                   isPresented: $viewModel.showingCancelAlert) {
                Button("Ya", role: .destructive) {
                    viewModel.isEditingMode = false
                }
                Button("Tidak", role: .cancel) { }
            } message: {
                Text(UIConstants.StudentDetailView.cancelConfirmationText)
            }
    }
    
    func showShareSheet(images: [UIImage]) {
        let activityVC = UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.frame.width / 2,
                                            y: window.frame.height / 2,
                                            width: 0,
                                            height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true)
        }
    }
}
