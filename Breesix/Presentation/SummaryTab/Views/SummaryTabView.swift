//
//  SummaryTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct SummaryTabView: View {
    @Binding var selectedTab: Int
    @Binding var isAddingStudent: Bool
    @ObservedObject var studentViewModel: StudentViewModel
    @ObservedObject var noteViewModel: NoteViewModel
    @ObservedObject var activityViewModel: ActivityViewModel
    @ObservedObject var summaryViewModel: SummaryViewModel
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
    
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showNoInternetAlert = false
    @EnvironmentObject var tabBarController: TabBarController

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CustomNavigation(
                    title: "Dokumentasi", textButton: "Dokumentasi",
                    isInternetConnected: networkMonitor.isConnected
                ) { if !networkMonitor.isConnected {
                    showNoInternetAlert = true
                }
                    else if studentViewModel.students.isEmpty {
                        showEmptyStudentsAlert = true
                    } else {
                        isShowingInputTypeSheet = true
                    }
                }
                
                DateSlider(selectedDate: $summaryViewModel.selectedDate)
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
                    selectedDate: $summaryViewModel.selectedDate,
                    isShowingPreview: $navigateToPreview,
                    isShowingActivity: .constant(false),
                    students: studentViewModel.students,
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
                    }
                )
                .background(.white)
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
                    onDismiss: {
                        isNavigatingToTextInput = false
                        navigateToPreview = true
                    },
                    fetchStudents: {
                        await studentViewModel.fetchAllStudents()
                        return studentViewModel.students
                    }
                )
            }
        }
        .tint(.accent)
        .accentColor(.accent)
        .buttonStyle(AccentButtonStyle())
        .alert("Tidak Ada Murid", isPresented: $showEmptyStudentsAlert) {
            Button("Tambahkan Murid",role: .cancel) {
                selectedTab = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isAddingStudent = true
                }
                
            }
            .modifier(AlertModifier())

        } message: {
            Text("Anda masih belum memiliki Daftar Murid. Tambahkan murid Anda ke dalam Gako melalu menu Murid")
        }
        
        .alert("Tidak Ada Koneksi Internet", isPresented: $showNoInternetAlert) {
            Button("OK", role: .cancel) {}
                .modifier(AlertModifier())
                
        }
        message: {
            Text("Pastikan Anda Terhubung ke internet untuk menggunkan fitur ini")
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

    @ViewBuilder private func datePickerView() -> some View {
        DatePicker("Select Date", selection: $summaryViewModel.selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }

    @ViewBuilder private func studentsListView() -> some View {
        VStack(spacing: 12) {
            ForEach(studentsWithSummariesOnSelectedDate) { student in
                NavigationLink(value: student) {
                    SummaryCard(student: student, selectedDate: summaryViewModel.selectedDate)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 72)
        .navigationDestination(for: Student.self) { student in
            DailyReportView(
                student: student,
                initialDate: summaryViewModel.selectedDate,  // Tambahkan ini
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
    
}

struct AlertModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.accent)
            .tint(.accent)
    }
}

