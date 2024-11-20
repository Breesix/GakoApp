//
//  DailyReportView.swift
//  GAKO
//
//  Created by Rangga Biner on 08/11/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: View to show daily activities and notes for student
//

import SwiftUI

struct DailyReportView: View {
    // MARK: - UI Constants
    private let navigationHeight = UIConstants.CustomNavigation.height
    private let navigationPadding = UIConstants.CustomNavigation.padding
    private let navigationCornerRadius = UIConstants.CustomNavigation.cornerRadius
    private let navigationBgColor = UIConstants.CustomNavigation.bgColor
    private let navigationTitleColor = UIConstants.CustomNavigation.titleColor
    
    private let buttonCornerRadius: CGFloat = 12
    private let buttonHeight: CGFloat = 50
    private let defaultPadding: CGFloat = 16
    private let defaultVerticalPadding: CGFloat = 12
    
    private let emptyStateImage = UIConstants.EmptyState.image
    private let emptyStateTextColor = UIConstants.EmptyState.textColor
    private let emptyStateSpacing = UIConstants.EmptyState.defaultSpacing
    
    // MARK: - Properties
    @StateObject private var viewModel: DailyReportViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    init(student: Student,
         initialDate: Date,
         onAddNote: @escaping (Note, Student) async -> Void,
         onUpdateNote: @escaping (Note) async -> Void,
         onDeleteNote: @escaping (Note, Student) async -> Void,
         onAddActivity: @escaping (Activity, Student) async -> Void,
         onDeleteActivity: @escaping (Activity, Student) async -> Void,
         onUpdateActivityStatus: @escaping (Activity, Status) async -> Void,
         onFetchNotes: @escaping (Student) async -> [Note],
         onFetchActivities: @escaping (Student) async -> [Activity]) {
        _viewModel = StateObject(wrappedValue: DailyReportViewModel(
            student: student,
            initialDate: initialDate,
            onAddNote: onAddNote,
            onUpdateNote: onUpdateNote,
            onDeleteNote: onDeleteNote,
            onAddActivity: onAddActivity,
            onDeleteActivity: onDeleteActivity,
            onUpdateActivityStatus: onUpdateActivityStatus,
            onFetchNotes: onFetchNotes,
            onFetchActivities: onFetchActivities
        ))
    }
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    navigationBgColor
                        .cornerRadius(navigationCornerRadius, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(edges: .top)
                    
                    ZStack {
                        navigationHeader
                    }
                }
                .frame(height: navigationHeight)
                
                VStack(spacing: 0) {
                    dateSelectionHeader
                    
                    if viewModel.activitiesForSelectedDay[Calendar.current.startOfDay(for: viewModel.selectedDate)]?.activities.isEmpty ?? true {
                        VStack {
                            emptyStateView
                        }
                    } else {
                        ScrollViewContent
                    }
                    bottomButton
                }
            }
            
            if viewModel.showSnapshotPreview {
                SnapshotPreview(
                    images: viewModel.allPageSnapshots,
                    currentPageIndex: $viewModel.currentPageIndex,
                    showSnapshotPreview: $viewModel.showSnapshotPreview,
                    toast: $viewModel.toast,
                    shareToWhatsApp: viewModel.shareToWhatsApp,
                    showShareSheet: viewModel.showShareSheet
                )
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .hideTabBar()
        .toastView(toast: $viewModel.toast)
        .alert("Peringatan", isPresented: $viewModel.showEmptyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.emptyAlertMessage)
        }
        .alert("No Activity", isPresented: $viewModel.noActivityAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("There are no activities recorded for the selected date.")
        }
        .alert("Peringatan", isPresented: $viewModel.showingCancelAlert) {
            Button("Ya", role: .destructive) {
                viewModel.isEditingMode = false
            }
            Button("Tidak", role: .cancel) { }
        } message: {
            Text("Apakah Anda yakin ingin membatalkan perubahan?")
        }
        .sheet(isPresented: $viewModel.isAddingNewActivity) {
            ManageActivityView(
                mode: .add,
                student: viewModel.student,
                selectedDate: viewModel.selectedDate,
                onDismiss: { viewModel.isAddingNewActivity = false },
                onSave: { newActivity in
                    Task {
                        await viewModel.onAddActivity(newActivity, viewModel.student)
                        await viewModel.fetchInitialData()
                    }
                },
                onUpdate: { _ in }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.activityToEdit) { activity in
            ManageActivityView(
                mode: .edit(activity),
                student: viewModel.student,
                selectedDate: viewModel.selectedDate,
                onDismiss: { viewModel.activityToEdit = nil },
                onSave: { _ in },
                onUpdate: { updatedActivity in
                    Task {
                        await viewModel.onUpdateActivityStatus(updatedActivity, updatedActivity.status)
                        await viewModel.fetchInitialData()
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.noteToEdit) { note in
            ManageNoteView(
                mode: .edit(note),
                student: viewModel.student,
                selectedDate: viewModel.selectedDate,
                onDismiss: { viewModel.noteToEdit = nil },
                onSave: { note in
                    await viewModel.onAddNote(note, viewModel.student)
                },
                onUpdate: { updatedNote in
                    Task {
                        await viewModel.onUpdateNote(updatedNote)
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .sheet(isPresented: $viewModel.isAddingNewNote) {
            ManageNoteView(
                mode: .add,
                student: viewModel.student,
                selectedDate: viewModel.selectedDate,
                onDismiss: {
                    viewModel.isAddingNewNote = false
                    Task {
                        await viewModel.fetchInitialData()
                    }
                },
                onSave: { note in
                    await viewModel.onAddNote(note, viewModel.student)
                },
                onUpdate: { _ in }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .task {
            await viewModel.fetchInitialData()
        }
    }
    
    // MARK: - View Components
    private var editButton: some View {
        Button(action: { viewModel.isEditingMode.toggle() }) {
            Text(!viewModel.isEditingMode ? "Edit" : "")
                .foregroundColor(navigationTitleColor)
        }
    }
    
    private var navigationHeader: some View {
        HStack(spacing: 0) {
            backButton
            Spacer()
            if !viewModel.isEditingMode {
                editButton
            }
        }
        .padding(.horizontal, navigationPadding)
        .overlay(navigationTitle)
    }
    
    private var backButton: some View {
        Button {
            !viewModel.isEditingMode ? presentationMode.wrappedValue.dismiss() : (viewModel.showingCancelAlert = true)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "chevron.left")
                    .foregroundColor(navigationTitleColor)
                    .fontWeight(.semibold)
                Text(!viewModel.isEditingMode ? "Ringkasan" : viewModel.student.nickname)
                    .foregroundStyle(navigationTitleColor)
                    .fontWeight(.regular)
            }
            .font(.body)
        }
    }
    
    private var navigationTitle: some View {
        Text(!viewModel.isEditingMode ? viewModel.student.nickname : viewModel.formattedDate)
            .fontWeight(.semibold)
            .foregroundStyle(navigationTitleColor)
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            EmptyState(message: "Belum ada aktivitas yang tercatat.")
            Spacer()
        }
    }
    
    private var bottomButton: some View {
        Group {
            if viewModel.isEditingMode {
                saveButton
            } else {
                shareButton
            }
        }
        .padding(.horizontal, defaultPadding)
        .padding(.vertical, defaultVerticalPadding)
    }
    
    private var saveButton: some View {
        Button {
            Task {
                await viewModel.saveChanges()
                viewModel.isEditingMode = false
            }
        } label: {
            Text("Simpan")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(Color(.orangeClickAble))
                .cornerRadius(buttonCornerRadius)
        }
    }
    
    private var shareButton: some View {
        Button {
            viewModel.validateAndShare()
        } label: {
            Text("Bagikan Dokumentasi")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .frame(maxWidth: .infinity)
                .frame(height: buttonHeight)
                .background(Color(.orangeClickAble))
                .cornerRadius(buttonCornerRadius)
        }
    }
    
    private var dateSelectionHeader: some View {
        HStack {
            Text(viewModel.formattedDate)
                .fontWeight(.semibold)
                .foregroundColor(.labelPrimaryBlack)
            
            HStack(spacing: 8) {
                Button(action: { viewModel.moveDay(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.buttonLinkOnSheet)
                }
                
                Button(action: { viewModel.moveDay(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Calendar.current.isDateInToday(viewModel.selectedDate) ? .gray : .buttonLinkOnSheet)
                }
                .disabled(Calendar.current.isDateInToday(viewModel.selectedDate))
            }
            
            Spacer()
            
            CalendarButton(
                selectedDate: $viewModel.selectedDate,
                isShowingCalendar: $viewModel.isShowingCalendar,
                onDateSelected: { newDate in
                    if viewModel.activitiesForSelectedDay[Calendar.current.startOfDay(for: newDate)] != nil {
                    } else {
                        if viewModel.selectedDate > Date() {
                            viewModel.noActivityAlertPresented = true
                        } else {
                            viewModel.noActivityAlertPresented = false
                        }
                    }
                }
            )
        }
        .padding(.horizontal, defaultPadding)
        .padding(.vertical, defaultVerticalPadding)
    }
    
    private var ScrollViewContent: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if viewModel.isEditingMode {
                        if let dayItems = viewModel.activitiesForSelectedDay[Calendar.current.startOfDay(for: viewModel.selectedDate)] {
                            DailyEditCard(
                                date: viewModel.selectedDate,
                                activities: dayItems.activities,
                                notes: dayItems.notes,
                                student: viewModel.student,
                                selectedStudent: .constant(nil),
                                isAddingNewActivity: $viewModel.isAddingNewActivity,
                                editedActivities: $viewModel.editedActivities,
                                editedNotes: $viewModel.editedNotes,
                                onDeleteActivity: viewModel.deleteActivity,
                                onDeleteNote: viewModel.deleteNote,
                                onActivityUpdate: { activity in
                                    viewModel.activityToEdit = activity
                                },
                                onAddActivity: {
                                    viewModel.isAddingNewActivity = true
                                },
                                onUpdateActivityStatus: viewModel.onUpdateActivityStatus,
                                onEditNote: { note in
                                    viewModel.noteToEdit = note
                                },
                                onAddNote: { _ in
                                    viewModel.isAddingNewNote = true
                                }
                            )
                            .padding(.horizontal, defaultPadding)
                            .padding(.bottom, defaultVerticalPadding)
                        }
                    } else {
                        if let dayItems = viewModel.activitiesForSelectedDay[Calendar.current.startOfDay(for: viewModel.selectedDate)] {
                            StudentDailyReportCard(
                                activities: dayItems.activities,
                                notes: dayItems.notes,
                                student: viewModel.student,
                                date: viewModel.selectedDate,
                                onAddNote: { viewModel.isAddingNewNote = true },
                                onAddActivity: { viewModel.isAddingNewActivity = true },
                                onDeleteActivity: viewModel.deleteActivity,
                                onEditNote: { viewModel.noteToEdit = $0 },
                                onDeleteNote: viewModel.deleteNote,
                                onShareTapped: { date in
                                    viewModel.generateSnapshot(for: date)
                                    withAnimation {
                                        viewModel.showSnapshotPreview = true
                                    }
                                },
                                onUpdateActivityStatus: { activity, newStatus in
                                    await viewModel.onUpdateActivityStatus(activity, newStatus)
                                }
                            )
                            .padding(.horizontal, defaultPadding)
                            .padding(.bottom, defaultVerticalPadding)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DailyReportView(
        student: Student(
            fullname: "John Doe",
            nickname: "John"
        ),
        initialDate: Date(),
        onAddNote: { _, _ in },
        onUpdateNote: { _ in },
        onDeleteNote: { _, _ in },
        onAddActivity: { _, _ in },
        onDeleteActivity: { _, _ in },
        onUpdateActivityStatus: { _, _ in },
        onFetchNotes: { _ in return [] },
        onFetchActivities: { _ in return [] }
    )
}
