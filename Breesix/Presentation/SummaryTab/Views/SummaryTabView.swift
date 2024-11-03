//
//  SummaryTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct SummaryTabView: View {
    @StateObject private var viewModel = SummaryTabViewModel()
    @ObservedObject var studentTabViewModel: StudentTabViewModel
    @State private var isAddingNewActivity = false
    @State private var isShowingPreview = false
    @State private var isShowingActivity = false
    @State private var isAllStudentsFilled = true
    @State private var isShowingInputTypeSheet = false
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false
    @State private var navigateToPreview = false
    @State private var searchText = ""
    @State private var showTabBar = true
    @State private var hideTabBar = false
    @State private var showEmptyStudentsAlert: Bool = false
    @EnvironmentObject var tabBarController: TabBarController

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CustomNavigation(title: "Ringkasan") {
                    if studentTabViewModel.students.isEmpty {
                        showEmptyStudentsAlert = true
                    } else {
                        isShowingInputTypeSheet = true
                    }
                }
                
                DateSlider(selectedDate: $viewModel.selectedDate)
                    .padding(.vertical, 12)
                
                Group {
                    if studentsWithSummariesOnSelectedDate.isEmpty {
                        VStack {
                            Spacer()
                            EmptyState(message: "Belum ada catatan di hari ini.")
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
            .sheet(isPresented: $isShowingInputTypeSheet) {
                InputTypeView(onSelect: { selectedInput in
                    switch selectedInput {
                    case .voice:
                        isShowingInputTypeSheet = false
                        isNavigatingToVoiceInput = true
                    case .text:
                        isShowingInputTypeSheet = false
                        isNavigatingToTextInput = true
                    }
                })
                .background(.white)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToPreview) {
                PreviewView(
                    selectedDate: $viewModel.selectedDate,
                    isShowingPreview: $navigateToPreview,
                    isShowingActivity: .constant(false),
                    students: studentTabViewModel.students,
                    unsavedActivities: studentTabViewModel.unsavedActivities,
                    unsavedNotes: studentTabViewModel.unsavedNotes,
                    onAddUnsavedActivities: { activities in
                        studentTabViewModel.addUnsavedActivities(activities)
                    },
                    onUpdateUnsavedActivity: { activity in
                        if let index = studentTabViewModel.unsavedActivities.firstIndex(where: { $0.id == activity.id }) {
                            studentTabViewModel.unsavedActivities[index] = activity
                        }
                    },
                    onDeleteUnsavedActivity: { activity in
                        studentTabViewModel.deleteUnsavedActivity(activity)
                    },
                    onAddUnsavedNote: { note in
                        studentTabViewModel.addUnsavedNote(note)
                    },
                    onUpdateUnsavedNote: { note in
                        studentTabViewModel.updateUnsavedNote(note)
                    },
                    onDeleteUnsavedNote: { note in
                        studentTabViewModel.deleteUnsavedNote(note)
                    },
                    onClearUnsavedNotes: {
                        studentTabViewModel.clearUnsavedNotes()
                    },
                    onClearUnsavedActivities: {
                        studentTabViewModel.clearUnsavedActivities()
                    },
                    onSaveUnsavedActivities: {
                        await studentTabViewModel.saveUnsavedActivities()
                    },
                    onSaveUnsavedNotes: {
                        await studentTabViewModel.saveUnsavedNotes()
                    },
                    onGenerateAndSaveSummaries: { date in
                        try await studentTabViewModel.generateAndSaveSummaries(for: date)
                    }
                )
            }
            .navigationDestination(isPresented: $isNavigatingToVoiceInput) {
                VoiceInputView(
                    selectedDate: $viewModel.selectedDate,
                    viewModel: studentTabViewModel,
                    onDismiss: {
                        isNavigatingToVoiceInput = false
                        navigateToPreview = true
                    }
                )
                .background(.white)
            }
            .navigationDestination(isPresented: $isNavigatingToTextInput) {
                TextInputView(
                    selectedDate: $viewModel.selectedDate,
                    onAddUnsavedActivities: { activities in
                        studentTabViewModel.addUnsavedActivities(activities)
                    },
                    onAddUnsavedNotes: { notes in
                        studentTabViewModel.addUnsavedNotes(notes)
                    },
                    onDateSelected: { date in
                        studentTabViewModel.selectedDate = date
                    },
                    onDismiss: {
                        isNavigatingToTextInput = false
                        navigateToPreview = true
                    },
                    fetchStudents: {
                        await studentTabViewModel.fetchAllStudents()
                        return studentTabViewModel.students
                    }
                )
            }
        }
        .alert("Tidak Ada Murid", isPresented: $showEmptyStudentsAlert) {
            Button("Tambahkan Murid", role: .cancel) {}
        } message: {
            Text("Anda masih belum memiliki Daftar Murid. Tambahkan murid Anda ke dalam Gako melalu menu Murid")
        }
        .navigationBarHidden(true)
        .task {
            await studentTabViewModel.fetchAllStudents()
        }
    }

    private var studentsWithSummariesOnSelectedDate: [Student] {
        if searchText.isEmpty {
            return studentTabViewModel.students.filter { student in
                student.summaries.contains { summary in
                    Calendar.current.isDate(summary.createdAt, inSameDayAs: viewModel.selectedDate)
                }
            }
        } else {
            return studentTabViewModel.students.filter { student in
                (student.fullname.lowercased().contains(searchText.lowercased()) ||
                 student.nickname.lowercased().contains(searchText.lowercased())) &&
                student.summaries.contains { summary in
                    Calendar.current.isDate(summary.createdAt, inSameDayAs: viewModel.selectedDate)
                }
            }
        }
    }

    @ViewBuilder private func datePickerView() -> some View {
        DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }

    @ViewBuilder private func studentsListView() -> some View {
        VStack(spacing: 12) {
            ForEach(studentsWithSummariesOnSelectedDate) { student in
                NavigationLink(value: student) {
                    SummaryCard(student: student, selectedDate: viewModel.selectedDate)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 72)
        .navigationDestination(for: Student.self) { student in
            StudentDetailView(
                student: student,
                onAddStudent: { student in
                    Task {
                        await studentTabViewModel.addStudent(student)
                    }
                },
                onUpdateStudent: { student in
                    Task {
                        await studentTabViewModel.updateStudent(student)
                    }
                },
                onAddNote: { note, student in
                    Task {
                        await studentTabViewModel.addNote(note, for: student)
                    }
                },
                onUpdateNote: { note in
                    Task {
                        await studentTabViewModel.updateNote(note)
                    }
                },
                onDeleteNote: { note, student in
                    Task {
                        await studentTabViewModel.deleteNote(note, from: student)
                    }
                },
                onAddActivity: { activity, student in
                    Task {
                        await studentTabViewModel.addActivity(activity, for: student)
                    }
                },
                onDeleteActivity: { activity, student in
                    Task {
                        await studentTabViewModel.deleteActivities(activity, from: student)
                    }
                },
                onUpdateActivityStatus: { activity, newStatus in
                    Task {
                        await studentTabViewModel.updateActivityStatus(activity, isIndependent: newStatus)
                    }
                },
                onFetchNotes: { student in
                    await studentTabViewModel.fetchAllNotes(student)
                },
                onFetchActivities: { student in
                    await studentTabViewModel.fetchActivities(student)
                },
                onCheckNickname: { nickname, currentStudentId in
                    studentTabViewModel.students.contains { student in
                        if let currentId = currentStudentId {
                            return student.nickname.lowercased() == nickname.lowercased() && student.id != currentId
                        }
                        return student.nickname.lowercased() == nickname.lowercased()
                    }
                },
                compressedImageData: studentTabViewModel.compressedImageData
            )
        }
    }
}
