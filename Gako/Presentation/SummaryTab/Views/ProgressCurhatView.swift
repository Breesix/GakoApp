//
//  ProgressCurhatView.swift
//  GAKO
//
//  Created by Rangga Biner on 13/11/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: View for user to list daily student presence and activities
//

import SwiftUI
import SwiftData

struct ProgressCurhatView: View {
    // MARK: - UI Constants
    private let padding: CGFloat = UIConstants.ProgressCurhat.padding
    private let cornerRadius: CGFloat = UIConstants.ProgressCurhat.cornerRadius
    private let backgroundColor: Color = UIConstants.ProgressCurhat.backgroundColor
    private let deleteButtonColor: Color = UIConstants.ProgressCurhat.deleteButtonColor
    private let trashIconName: String = UIConstants.ProgressCurhat.trashIconName

    @State private var firstColor: Color = .bgAccent
    @State private var secondColor: Color = .bgMain
    @State private var thirdColor: Color = .bgMain
    @State private var isToggleOn = false
    @State private var isShowingDatePicker = false
    @State private var showAlert: Bool = false
    @State private var isShowingInputTypeSheet = false
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false
    @State private var navigateToPreview = false

    @State private var showManageActivity: Bool = false
    @State private var activityText: String = ""
    @State private var currentProgress: Int = 1
    @State private var editingActivity: (index: Int, text: String)? = nil
    @State private var showEmptyStudentsAlert: Bool = false
    @State private var showEmptyActivitiesAlert: Bool = false
    @State private var showDeleteAlert = false
    @State private var activityToDelete: Int?

    @Binding var selectedDate: Date
    
    var onNavigateVoiceInput: () -> Void
    var onNavigateTextInput: () -> Void

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var summaryViewModel: SummaryViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    ProgressTracker(firstColor: firstColor, secondColor: secondColor, thirdColor: thirdColor)
                    Spacer()
                    DatePickerButton(isShowingDatePicker: $isShowingDatePicker, selectedDate: $selectedDate)
                }
                TitleProgressCard(title: currentTitle, subtitle: currentSubtitle)

                if currentProgress == 3 {
                  VStack(alignment:.leading, spacing: 12) {
                    GuidingQuestionTag(text: UIConstants.ProgressCurhat.guidingQuestion1)
                    GuidingQuestionTag(text: UIConstants.ProgressCurhat.guidingQuestion2)
                    GuidingQuestionTag(text: UIConstants.ProgressCurhat.guidingQuestion3)
                }
                Spacer()
                TipsCard()
                    .padding(.vertical, 16)
                Divider()
                } else if currentProgress == 1 {
     
                    AttendanceToggle(isToggleOn: $isToggleOn, students: studentViewModel.students)
                    StudentGridView(students: studentViewModel.students,  onDeleteStudent: { student in
                        await studentViewModel.deleteStudent(student)
                    })
                } else if currentProgress == 2 {
                 
                    activityInputs()
                }
                navigationButtons()
            }
            .sheet(isPresented: $isShowingInputTypeSheet) {
                InputTypeView { selectedInput in
                    isShowingInputTypeSheet = false
                    switch selectedInput {
                    case .voice:
                        onNavigateVoiceInput()
                    case .text:
                        onNavigateTextInput()
                    }
                }
                .presentationDetents([.medium])
            }
            .padding(.horizontal, 16)
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .hideTabBar()
        }
        .alert(UIConstants.ProgressCurhat.selectStudentAlertTitle, isPresented: $showEmptyStudentsAlert) {
            Button(UIConstants.ProgressCurhat.okButtonText, role: .cancel, action: {})
        } message: {
            Text(UIConstants.ProgressCurhat.selectStudentAlertMessage)
        }
        .alert(UIConstants.ProgressCurhat.cancelDocumentationAlertTitle, isPresented: $showAlert) {
            Button(UIConstants.ProgressCurhat.cancelDocumentationButtonText, role: .destructive) {
                studentViewModel.activities.removeAll()
                studentViewModel.selectedStudents.removeAll()
                presentationMode.wrappedValue.dismiss()
            }
            Button(UIConstants.ProgressCurhat.continueDocumentationButtonText, role: .cancel) {}
        } message: {
            Text(UIConstants.ProgressCurhat.cancelDocumentationAlertMessage)
        }
        .alert(UIConstants.ProgressCurhat.addActivityAlertTitle, isPresented: $showEmptyActivitiesAlert) {
            Button(UIConstants.ProgressCurhat.okButtonText, role: .cancel, action: {})
        } message: {
            Text(UIConstants.ProgressCurhat.addActivityAlertMessage)
        }
        .alert(UIConstants.ProgressCurhat.deleteActivityAlertTitle, isPresented: $showDeleteAlert) {
            Button(UIConstants.ProgressCurhat.cancelButtonText, role: .cancel) { }
            Button(UIConstants.ProgressCurhat.deleteButtonText, role: .destructive) {
                if let index = activityToDelete {
                    studentViewModel.activities.remove(at: index)
                }
            }
        } message: {
            Text(UIConstants.ProgressCurhat.deleteActivityAlertMessage)
        }
        .task {
            await studentViewModel.fetchAllStudents()
        }
    }

    private var currentTitle: String {
        switch currentProgress {
        case 1: return UIConstants.ProgressCurhat.currentTitle1
        case 2: return UIConstants.ProgressCurhat.currentTitle2
        case 3: return UIConstants.ProgressCurhat.currentTitle3
        default: return ""
        }
    }

    private var currentSubtitle: String {
        switch currentProgress {
        case 1: return UIConstants.ProgressCurhat.currentSubtitle1
        case 2: return UIConstants.ProgressCurhat.currentSubtitle2
        case 3: return UIConstants.ProgressCurhat.currentSubtitle3
        default: return ""
        }
    }

    private func activityInputs() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(studentViewModel.activities.indices, id: \.self) { index in
                    ActivityCard(
                        activity: studentViewModel.activities[index],
                        onTap: {
                            editingActivity = (index, studentViewModel.activities[index])
                            activityText = studentViewModel.activities[index]
                            showManageActivity = true
                        },
                        onDelete: {
                            activityToDelete = index
                            showDeleteAlert = true
                        }
                    )

                }
                
                AddItemButton(
                    onTapAction: {
                        showManageActivity = true
                    },
                    bgColor: .buttonOncard,
                    text: UIConstants.ProgressCurhat.addText
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }

            .sheet(isPresented: $showManageActivity) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(editingActivity == nil ? UIConstants.ProgressCurhat.addActivityText : UIConstants.ProgressCurhat.editActivityText)
                            .foregroundStyle(.labelPrimaryBlack)
                            .font(.callout)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ZStack(alignment: .leading) {
                                if activityText.isEmpty {
                                    Text(UIConstants.ProgressCurhat.writeActivityPlaceholder)
                                        .foregroundStyle(.labelTertiary)
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 9)
                                }
                                
                                TextField("", text: $activityText)
                                    .foregroundStyle(.labelPrimaryBlack)
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 9)
                            }
                            .background(backgroundColor)
                            .cornerRadius(cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(.monochrome50, lineWidth: 0.5)
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 34.5)
                    .padding(.horizontal, 16)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(editingActivity == nil ? UIConstants.ProgressCurhat.addActivityText : UIConstants.ProgressCurhat.editActivityText)
                                .foregroundStyle(.labelPrimaryBlack)
                                .font(.body)
                                .fontWeight(.semibold)
                                .padding(.top, 27)
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showManageActivity = false
                                editingActivity = nil
                                activityText = ""
                            }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "chevron.left")
                                        .fontWeight(.semibold)
                                    Text(UIConstants.ProgressCurhat.backButtonText)
                                }
                                .font(.body)
                                .fontWeight(.medium)
                            }
                            .padding(.top, 27)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                if !activityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    if let editing = editingActivity {
                                        studentViewModel.activities[editing.index] = activityText
                                    } else {
                                        studentViewModel.activities.append(activityText)
                                    }
                                    activityText = ""
                                    editingActivity = nil
                                    showManageActivity = false
                                }
                            }) {
                                Text(UIConstants.ProgressCurhat.saveButtonText)
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.top, 27)
                        }
                    }
                }
            }
        }

    private func navigationButtons() -> some View {
        HStack {
            Button {
                if currentProgress > 1 {
                    currentProgress -= 1
                    updateProgressColors()
                } else {
                    showAlert = true
                }
            } label: {
                Text(currentProgress > 1 ? UIConstants.ProgressCurhat.backText : UIConstants.ProgressCurhat.cancelText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(12)
            }
            
            Button {
                if currentProgress == 1 && studentViewModel.selectedStudents.isEmpty {
                    showEmptyStudentsAlert = true
                } else if currentProgress == 2 && studentViewModel.activities.isEmpty {
                    showEmptyActivitiesAlert = true
                } else if currentProgress < 3 {
                    currentProgress += 1
                    updateProgressColors()
                } else if currentProgress == 3 {
                    isShowingInputTypeSheet = true
                    print(studentViewModel.activities)
                }
            } label: {
                Text(currentProgress == 3 ? UIConstants.ProgressCurhat.startStoryText : UIConstants.ProgressCurhat.continueText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.orangeClickAble)
                    .cornerRadius(12)
            }
        }
        .font(.body)
        .fontWeight(.semibold)
        .foregroundStyle(.labelPrimaryBlack)
    }

    private func updateProgressColors() {
        switch currentProgress {
        case 1:
            firstColor = .bgAccent
            secondColor = .bgMain
            thirdColor = .bgMain
        case 2:
            firstColor = .bgSecondary
            secondColor = .bgAccent
            thirdColor = .bgMain
        case 3:
            firstColor = .bgSecondary
            secondColor = .bgSecondary
            thirdColor = .bgAccent
        default:
            break
        }
    }
}

struct ActivityCard: View {
    let activity: String
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(activity)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.cardFieldBG)
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}
