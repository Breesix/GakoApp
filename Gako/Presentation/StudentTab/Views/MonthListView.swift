//
//  MonthListView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A view for displaying a list of months associated with a student
//  Usage: Use this view to manage and navigate through student activities and notes by month
//

import SwiftUI

struct MonthListView: View {
    // MARK: - Properties
    @StateObject var viewModel: MonthListViewModel
    @Environment(\.presentationMode)  var presentationMode
    
    // MARK: - Dependencies
     let student: Student
     let onAddStudent: (Student) async -> Void
     let onUpdateStudent: (Student) async -> Void
     let onAddNote: (Note, Student) async -> Void
     let onUpdateNote: (Note) async -> Void
     let onDeleteNote: (Note, Student) async -> Void
     let onAddActivity: (Activity, Student) async -> Void
     let onDeleteActivity: (Activity, Student) async -> Void
     let onUpdateActivityStatus: (Activity, Status) async -> Void
     let onFetchNotes: (Student) async -> [Note]
     let onFetchActivities: (Student) async -> [Activity]
     let onCheckNickname: (String, UUID?) -> Bool
     let compressedImageData: Data?
    
    // MARK: - Initialization
    init(student: Student,
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
         onCheckNickname: @escaping (String, UUID?) -> Bool,
         compressedImageData: Data?) {

        self.student = student
        self.onAddStudent = onAddStudent
        self.onUpdateStudent = onUpdateStudent
        self.onAddNote = onAddNote
        self.onUpdateNote = onUpdateNote
        self.onDeleteNote = onDeleteNote
        self.onAddActivity = onAddActivity
        self.onDeleteActivity = onDeleteActivity
        self.onUpdateActivityStatus = onUpdateActivityStatus
        self.onFetchNotes = onFetchNotes
        self.onFetchActivities = onFetchActivities
        self.onCheckNickname = onCheckNickname
        self.compressedImageData = compressedImageData
        
        _viewModel = StateObject(wrappedValue: MonthListViewModel(
            student: student,
            onFetchActivities: onFetchActivities,
            onFetchNotes: onFetchNotes
        ))
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            UIConstants.MonthListView.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                contentView
            }
        }
        .toolbar(.hidden, for: .bottomBar, .tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .hideTabBar()
        .task {
            await viewModel.fetchData()
        }
        .sheet(isPresented: $viewModel.isShowingYearPicker) {
            YearPickerView(selectedDate: $viewModel.selectedYear)
                .presentationDetents([.fraction(0.3)])
        }
        .sheet(isPresented: $viewModel.isEditing) {
            ManageStudentView(
                mode: .edit(student),
                compressedImageData: compressedImageData,
                newStudentImage: viewModel.newStudentImage,
                onSave: onAddStudent,
                onUpdate: onUpdateStudent,
                onImageChange: viewModel.handleImageChange,
                checkNickname: onCheckNickname
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
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

    return MonthListView(
        student: sampleStudent,
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
        onCheckNickname: mockCheckNickname,
        compressedImageData: sampleCompressedImageData
    )
}
