//
//  MonthListView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/11/24.
//

import SwiftUI

struct MonthListView: View {
    // MARK: - Properties
    @StateObject private var viewModel: MonthListViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - Dependencies
    private let student: Student
    private let onAddStudent: (Student) async -> Void
    private let onUpdateStudent: (Student) async -> Void
    private let onAddNote: (Note, Student) async -> Void
    private let onUpdateNote: (Note) async -> Void
    private let onDeleteNote: (Note, Student) async -> Void
    private let onAddActivity: (Activity, Student) async -> Void
    private let onDeleteActivity: (Activity, Student) async -> Void
    private let onUpdateActivityStatus: (Activity, Status) async -> Void
    private let onFetchNotes: (Student) async -> [Note]
    private let onFetchActivities: (Student) async -> [Activity]
    private let onCheckNickname: (String, UUID?) -> Bool
    private let compressedImageData: Data?
    
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
            UIConstants.MonthList.backgroundColor.ignoresSafeArea()
            
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

// MARK: - View Components
private extension MonthListView {
    var headerView: some View {
        ZStack {
            UIConstants.MonthList.headerBackgroundColor
                .cornerRadius(UIConstants.MonthList.cornerRadius, corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea(edges: .top)
            
            HStack {
                backButton
                Spacer()
                editButton
            }
            .padding(UIConstants.MonthList.headerPadding)
        }
        .frame(height: UIConstants.MonthList.headerHeight)
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 3) {
                Image(systemName: UIConstants.MonthList.backIcon)
                    .foregroundColor(UIConstants.MonthList.headerTextColor)
                    .fontWeight(.semibold)
                Text(UIConstants.MonthList.backText)
                    .foregroundStyle(UIConstants.MonthList.headerTextColor)
                    .font(.body)
                    .fontWeight(.regular)
            }
        }
    }
    
    var editButton: some View {
        Button(action: viewModel.toggleEditing) {
            Text(UIConstants.MonthList.editProfileText)
                .foregroundStyle(UIConstants.MonthList.headerTextColor)
                .font(.body)
                .fontWeight(.regular)
        }
    }
    
    var contentView: some View {
        VStack(spacing: UIConstants.MonthList.spacing) {
            ProfileHeader(student: student)
                .padding(.horizontal, UIConstants.MonthList.contentPadding.leading)
            
            Divider()
                .padding(.bottom, UIConstants.MonthList.dividerPadding)
            
            documentationHeader
            monthList
        }
        .padding(.top, UIConstants.MonthList.contentPadding.top)
    }
    
    var documentationHeader: some View {
        HStack(spacing: UIConstants.MonthList.monthNavigationSpacing) {
            Text(UIConstants.MonthList.documentationText)
                .fontWeight(.semibold)
                .foregroundColor(UIConstants.MonthList.documentationTextColor)
            
            Spacer()
            
            yearNavigationButtons
            yearPickerButton
        }
        .padding(.horizontal, UIConstants.MonthList.contentPadding.leading)
    }
    
    var yearNavigationButtons: some View {
        HStack(spacing: UIConstants.MonthList.monthNavigationSpacing) {
            Button(action: { viewModel.moveYear(by: -1) }) {
                Image(systemName: UIConstants.MonthList.backIcon)
                    .foregroundStyle(UIConstants.MonthList.monthNavigationColor)
            }
            
            Button(action: { viewModel.moveYear(by: 1) }) {
                Image(systemName: UIConstants.MonthList.nextIcon)
                    .foregroundStyle(viewModel.isNextYearDisabled ?
                        UIConstants.MonthList.monthNavigationDisabledColor :
                        UIConstants.MonthList.monthNavigationColor)
            }
            .disabled(viewModel.isNextYearDisabled)
        }
    }
    
    var yearPickerButton: some View {
        Button(action: viewModel.toggleYearPicker) {
            Text(viewModel.formattedYear)
                .font(.headline)
        }
        .padding(UIConstants.MonthList.yearPickerButtonPadding)
        .background(UIConstants.MonthList.yearPickerButtonBackground)
        .foregroundStyle(UIConstants.MonthList.yearPickerButtonText)
        .cornerRadius(UIConstants.MonthList.yearPickerButtonCornerRadius)
    }
    
    var monthList: some View {
        ScrollView {
            LazyVStack(spacing: UIConstants.MonthList.spacing) {
                ForEach(viewModel.getAllMonthsForYear(), id: \.self) { date in
                    NavigationLink(destination: makeStudentDetailView(for: date)) {
                        MonthCard(
                            date: date,
                            activitiesCount: viewModel.getActivityCount(for: date),
                            hasActivities: viewModel.hasActivities(for: date)
                        )
                    }
                }
            }
            .padding(.horizontal, UIConstants.MonthList.contentPadding.leading)
        }
    }
    
    func makeStudentDetailView(for date: Date) -> some View {
        StudentDetailView(
            student: student,
            initialScrollDate: date,
            compressedImageData: compressedImageData,
            onAddStudent: onAddStudent,
            onUpdateStudent: onUpdateStudent,
            onAddNote: onAddNote,
            onUpdateNote: onUpdateNote,
            onDeleteNote: onDeleteNote,
            onAddActivity: onAddActivity,
            onDeleteActivity: onDeleteActivity,
            onUpdateActivityStatus: onUpdateActivityStatus,
            onFetchNotes: onFetchNotes,
            onFetchActivities: onFetchActivities,
            onCheckNickname: onCheckNickname
        )
    }
}

