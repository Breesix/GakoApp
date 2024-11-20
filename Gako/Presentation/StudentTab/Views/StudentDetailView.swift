//
//  StudentDetailView.swift
//  Gako
//
//  Created by Rangga Biner on 03/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides UI components and layout for MonthListView
//  Usage: Contains methods for creating header views, navigation buttons, and month list display
//

import SwiftUI
import PhotosUI

struct StudentDetailView: View {
    // MARK: - Constants
    private let backgroundColor = UIConstants.StudentDetailView.backgroundColor
    private let noActivityTitle = UIConstants.StudentDetailView.noActivityTitle
    private let noActivityMessage = UIConstants.StudentDetailView.noActivityMessage
    private let warningTitle = UIConstants.StudentDetailView.warningTitle
    private let cancelConfirmationText = UIConstants.StudentDetailView.cancelConfirmationText
    
    // MARK: - Properties
    @StateObject var viewModel: StudentDetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - State Properties
    @State var isTabBarHidden = true
    @State var isAddingNewNote = false
    @State var isAddingNewActivity = false
    @State var activityToEdit: Activity?
    @State var noteToEdit: Note?
    @State var isEditing = false
    @State var newStudentImage: UIImage?
    
    // MARK: - Dependencies
    let student: Student
    let compressedImageData: Data?
    let onAddStudent: (Student) async -> Void
    let onUpdateStudent: (Student) async -> Void
    let onCheckNickname: (String, UUID?) -> Bool
    
    // MARK: - Initialization
    init(student: Student,
         initialScrollDate: Date,
         compressedImageData: Data?,
         onAddStudent: @escaping (Student) async -> Void,
         onUpdateStudent: @escaping (Student) async -> Void,
         onAddNote: @escaping (Note, Student) async -> Void,
         onUpdateNote: @escaping (Note) async -> Void,
         onDeleteNote: @escaping (Note, Student) async -> Void,
         onAddActivity: @escaping (Activity, Student) async -> Void,
         onDeleteActivity: @escaping (Activity, Student) async -> Void,
         onUpdateActivityStatus: @escaping (Activity, Status) async -> Void,
         onFetchNotes: @escaping (Student) async -> [Note],
         onFetchActivities: @escaping (Student) async -> [Activity],
         onCheckNickname: @escaping (String, UUID?) -> Bool) {
        
        self.student = student
        self.compressedImageData = compressedImageData
        self.onAddStudent = onAddStudent
        self.onUpdateStudent = onUpdateStudent
        self.onCheckNickname = onCheckNickname
        
        _viewModel = StateObject(wrappedValue: StudentDetailViewModel(
            student: student,
            initialDate: initialScrollDate,
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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                contentView
            }
            
            if viewModel.showSnapshotPreview {
                snapshotPreviewView
            }
        }
        .tint(.accent)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .hideTabBar()
        .sheet(item: $noteToEdit) { note in
            ManageNoteView(
                mode: .edit(note),
                student: student,
                selectedDate: viewModel.selectedDate,
                onDismiss: {
                    noteToEdit = nil
                },
                onSave: { note in
                    Task {
                        await viewModel.onAddNote(note, student)
                    }
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
        .sheet(isPresented: $isAddingNewNote) {
            ManageNoteView(
                mode: .add,
                student: student,
                selectedDate: viewModel.selectedDate,
                onDismiss: {
                    isAddingNewNote = false
                    Task {
                        await viewModel.fetchAllNotes()
                    }
                },
                onSave: { note in
                    Task {
                        await viewModel.onAddNote(note, student)
                    }
                },
                onUpdate: { _ in }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .sheet(isPresented: $isAddingNewActivity) {
            ManageActivityView(
                mode: .add,
                student: student,
                selectedDate: viewModel.selectedDate,
                onDismiss: { isAddingNewActivity = false },
                onSave: { newActivity in
                    Task {
                        await viewModel.onAddActivity(newActivity, student)
                        await viewModel.fetchActivities()
                    }
                },
                onUpdate: { _ in }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $activityToEdit) { activity in
            ManageActivityView(
                mode: .edit(activity),
                student: student,
                selectedDate: viewModel.selectedDate,
                onDismiss: { activityToEdit = nil },
                onSave: { _ in },
                onUpdate: { updatedActivity in
                    Task {
                        await viewModel.onUpdateActivityStatus(updatedActivity, updatedActivity.status)
                        await viewModel.fetchActivities()
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isEditing) {
            ManageStudentView(
                mode: .edit(student),
                compressedImageData: compressedImageData,
                newStudentImage: newStudentImage,
                onSave: onAddStudent,
                onUpdate: onUpdateStudent,
                onImageChange: { image in
                    newStudentImage = image
                },
                checkNickname: onCheckNickname
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .toastView(toast: $viewModel.toast)
        .alert(noActivityTitle,
               isPresented: $viewModel.noActivityAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(noActivityMessage)
        }
        .alert(warningTitle,
               isPresented: $viewModel.showingCancelAlert) {
            Button("Ya", role: .destructive) {
                viewModel.isEditingMode = false
            }
            Button("Tidak", role: .cancel) { }
        } message: {
            Text(cancelConfirmationText)
        }
        .task {
            await viewModel.fetchAllData()
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleStudent = Student(fullname: "John Doe", nickname: "Johnny")

    let mockAddStudent: (Student) async -> Void = { _ in }
    let mockUpdateStudent: (Student) async -> Void = { _ in }
    let mockAddNote: (Note, Student) async -> Void = { _, _ in }
    let mockUpdateNote: (Note) async -> Void = { _ in }
    let mockDeleteNote: (Note, Student) async -> Void = { _, _ in }
    let mockAddActivity: (Activity, Student) async -> Void = { _, _ in }
    let mockDeleteActivity: (Activity, Student) async -> Void = { _, _ in }
    let mockUpdateActivityStatus: (Activity, Status) async -> Void = { _, _ in }
    let mockFetchNotes: (Student) async -> [Note] = { _ in return [] }
    let mockFetchActivities: (Student) async -> [Activity] = { _ in return [] }
    let mockCheckNickname: (String, UUID?) -> Bool = { _, _ in return true }

    let sampleCompressedImageData: Data? = nil

    return StudentDetailView(
        student: sampleStudent,
        initialScrollDate: Date(),
        compressedImageData: sampleCompressedImageData,
        onAddStudent: mockAddStudent,
        onUpdateStudent: mockUpdateStudent,
        onAddNote: mockAddNote,
        onUpdateNote: mockUpdateNote,
        onDeleteNote: mockDeleteNote,
        onAddActivity: mockAddActivity,
        onDeleteActivity: mockDeleteActivity,
        onUpdateActivityStatus: mockUpdateActivityStatus,
        onFetchNotes: mockFetchNotes,
        onFetchActivities: mockFetchActivities,
        onCheckNickname: mockCheckNickname
    )
}
