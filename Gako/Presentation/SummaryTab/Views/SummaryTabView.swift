//
//  SummaryTabView.swift
//  GAKO
//
//  Created by Rangga Biner on 30/09/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: Main view of student Summary
//

import SwiftUI

struct SummaryTabView: View {
    @Binding var selectedTab: Int
    @Binding var isAddingStudent: Bool
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var summaryViewModel: SummaryViewModel
    @State private var isAddingNewActivity = false
    @State private var isShowingPreview = false
    @State private var isShowingActivity = false
    @State private var isAllStudentsFilled = true
    @State private var isShowingInputTypeSheet = false
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false
    @State private var navigateToPreview = false
    @State private var navigateToProgressCurhatan = false
    @State private var searchText = ""
    @State private var showTabBar = true
    @State private var hideTabBar = false
    @State private var showEmptyStudentsAlert: Bool = false
    
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showNoInternetAlert = false
    @EnvironmentObject var tabBarController: TabBarController

    var body: some View {
        let spacingNone = UIConstants.SummaryTab.Spacing.none
        let spacingSmall = UIConstants.SummaryTab.Spacing.small
        let navigationTitle = UIConstants.SummaryTab.Navigation.documentationTitle
        let navigationButtonText = UIConstants.SummaryTab.Navigation.documentationButtonText
        let noNotesMessage = UIConstants.SummaryTab.EmptyState.noNotesMessage
        let noStudentsTitle = UIConstants.SummaryTab.AlertMessages.noStudentsTitle
        let addStudentButtonText = UIConstants.SummaryTab.AlertMessages.addStudentButtonText
        let noStudentsMessage = UIConstants.SummaryTab.AlertMessages.noStudentsMessage
        let noInternetTitle = UIConstants.SummaryTab.AlertMessages.noInternetTitle
        let okButtonText = UIConstants.SummaryTab.AlertMessages.okButtonText
        let noInternetMessage = UIConstants.SummaryTab.AlertMessages.noInternetMessage
        let buttonDelay = UIConstants.SummaryTab.Animation.buttonDelay
        let spacingMedium = UIConstants.SummaryTab.Spacing.medium
        let bottomPadding = UIConstants.SummaryTab.Spacing.bottomPadding

        NavigationStack {
            VStack(spacing: spacingNone) {
                CustomNavigation(
                    title: navigationTitle,
                    textButton: navigationButtonText
                ) {
                    if (!networkMonitor.isConnected) {
                        showNoInternetAlert = true
                    } else if (studentViewModel.students.isEmpty) {
                        showEmptyStudentsAlert = true
                    } else {
                        navigateToProgressCurhatan = true
                    }
                }
                
                DateSlider(selectedDate: $summaryViewModel.selectedDate)
                    .padding(.vertical, spacingSmall)
                
                Group {
                    if (studentsWithSummariesOnSelectedDate.isEmpty) {
                        VStack {
                            Spacer()
                            EmptyState(message: noNotesMessage)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            studentsListView()
                        }
                    }
                }
            }
            .background(.bgMain)
            .navigationDestination(isPresented: $navigateToProgressCurhatan) {

                ProgressCurhatView(selectedDate: $summaryViewModel.selectedDate, onNavigateVoiceInput: {
                    isNavigatingToVoiceInput = true
                }, onNavigateTextInput: {
                    isNavigatingToTextInput = true
                }
                )
            }
            .navigationDestination(isPresented: $navigateToPreview) {
                PreviewView(
                    selectedDate: $summaryViewModel.selectedDate,
                    isShowingPreview: $navigateToPreview,
                    isShowingActivity: .constant(false),
                    students: studentViewModel.students,
                    selectedStudents: studentViewModel.selectedStudents,
                    unsavedActivities: activityViewModel.unsavedActivities,
                    unsavedNotes: noteViewModel.unsavedNotes,
                    onAddUnsavedActivities: { activities in
                        activityViewModel.addUnsavedActivities(activities)
                    },
                    onUpdateUnsavedActivity: { activity in
                        if let index = activityViewModel.unsavedActivities.firstIndex(where: { $0.id == activity.id }) {
                            activityViewModel.unsavedActivities[index] = activity
                        }
                    },
                    onDeleteUnsavedActivity: { activity in
                        activityViewModel.deleteUnsavedActivity(activity)
                    },
                    onAddUnsavedNote: { note in
                        noteViewModel.addUnsavedNote(note)
                    },
                    onUpdateUnsavedNote: { note in
                        noteViewModel.updateUnsavedNote(note)
                    },
                    onDeleteUnsavedNote: { note in
                        noteViewModel.deleteUnsavedNote(note)
                    },
                    onClearUnsavedNotes: {
                        noteViewModel.clearUnsavedNotes()
                    },
                    onClearUnsavedActivities: {
                        activityViewModel.clearUnsavedActivities()
                    },
                    onSaveUnsavedActivities: {
                        await activityViewModel.saveUnsavedActivities()
                    },
                    onSaveUnsavedNotes: {
                        await noteViewModel.saveUnsavedNotes()
                    },
                    onGenerateAndSaveSummaries: { date in
                        try await summaryViewModel.generateAndSaveSummaries(for: date)
                    }
                )
            }
            .navigationDestination(isPresented: $isNavigatingToVoiceInput) {
                VoiceInputView(
                    selectedDate: $summaryViewModel.selectedDate,
                    onAddUnsavedActivities: { activities in
                        activityViewModel.addUnsavedActivities(activities)
                    },
                    onAddUnsavedNotes: { notes in
                        noteViewModel.addUnsavedNotes(notes)
                    },
                    onDateSelected: { date in
                        summaryViewModel.selectedDate = date
                    },
                    onDismiss: {
                        isNavigatingToVoiceInput = false
                        navigateToPreview = true
                    },
                    fetchStudents: {
                        await studentViewModel.fetchAllStudents()
                        return studentViewModel.students
                    },
                    selectedStudents: studentViewModel.selectedStudents, // Pass selected students
                    activities: studentViewModel.activities // Pass activities

                )
                .interactiveDismissDisabled()
            }
            
            .navigationDestination(isPresented: $isNavigatingToTextInput) {
                TextInputView(
                    selectedDate: $summaryViewModel.selectedDate,
                    onAddUnsavedActivities: { activities in
                        activityViewModel.addUnsavedActivities(activities)
                    },
                    onAddUnsavedNotes: { notes in
                        noteViewModel.addUnsavedNotes(notes)
                    },
                    onDateSelected: { date in
                        summaryViewModel.selectedDate = date
                    },
                    selectedStudents: studentViewModel.selectedStudents, // Pass selected students
                    activities: studentViewModel.activities, // Pass activities
                    onDismiss: {
                        isNavigatingToTextInput = false
                        navigateToPreview = true
                    }
                )
                .interactiveDismissDisabled()
            }

        }
        .tint(.accent)
        .accentColor(.accent)
        .buttonStyle(AccentButtonStyle())
        .alert(noStudentsTitle, isPresented: $showEmptyStudentsAlert) {
            Button(addStudentButtonText, role: .cancel) {
                selectedTab = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + buttonDelay) {
                    isAddingStudent = true
                }
            }
            .modifier(AlertModifier())
        } message: {
            Text(noStudentsMessage)
        }
        
        .alert(noInternetTitle, isPresented: $showNoInternetAlert) {
            Button(okButtonText, role: .cancel) {}
                .modifier(AlertModifier())
        } message: {
            Text(noInternetMessage)
        }
        .navigationBarHidden(true)
        .task {
            await studentViewModel.fetchAllStudents()
        }
    }

    private var studentsWithSummariesOnSelectedDate: [Student] {
        if searchText.isEmpty {
            return studentViewModel.students.filter { student in
                student.summaries.contains { summary in
                    Calendar.current.isDate(summary.createdAt, inSameDayAs: summaryViewModel.selectedDate)
                }
            }
        } else {
            return studentViewModel.students.filter { student in
                (student.fullname.lowercased().contains(searchText.lowercased()) ||
                 student.nickname.lowercased().contains(searchText.lowercased())) &&
                student.summaries.contains { summary in
                    Calendar.current.isDate(summary.createdAt, inSameDayAs: summaryViewModel.selectedDate)
                }
            }
        }
    }

    // MARK: - Helper Views
    @ViewBuilder private func studentsListView() -> some View {
        VStack(spacing: UIConstants.SummaryTab.Spacing.small) {
            ForEach(studentsWithSummariesOnSelectedDate) { student in
                NavigationLink(value: student) {
                    SummaryCard(student: student, selectedDate: summaryViewModel.selectedDate)
                }
            }
        }
        .padding(.horizontal, UIConstants.SummaryTab.Spacing.medium)
        .padding(.bottom, UIConstants.SummaryTab.Spacing.bottomPadding)
        .navigationDestination(for: Student.self) { student in
            DailyReportView(
                student: student,
                initialDate: summaryViewModel.selectedDate,
                onAddNote: { note, student in
                    Task {
                        await noteViewModel.addNote(note, for: student)
                    }
                },
                onUpdateNote: { note in
                    Task {
                        await noteViewModel.updateNote(note)
                    }
                },
                onDeleteNote: { note, student in
                    Task {
                        await noteViewModel.deleteNote(note, from: student)
                    }
                },
                onAddActivity: { activity, student in
                    Task {
                        await activityViewModel.addActivity(activity, for: student)
                    }
                },
                onDeleteActivity: { activity, student in
                    await activityViewModel.deleteActivities(activity, from: student)
                },
                onUpdateActivityStatus: { activity, status in
                    await activityViewModel.updateActivityStatus(activity, status: status)
                },
                onFetchNotes: { student in
                    await noteViewModel.fetchAllNotes(student)
                },
                onFetchActivities: { student in
                    await activityViewModel.fetchActivities(student)
                }
            )
        }
    }
    
    @ViewBuilder private func datePickerView() -> some View {
        DatePicker("Select Date", selection: $summaryViewModel.selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }
}

struct AlertModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.accent)
            .tint(.accent)
    }
}

