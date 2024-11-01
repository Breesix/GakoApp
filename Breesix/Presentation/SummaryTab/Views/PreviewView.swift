//
//  PreviewView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct PreviewView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowingPreview: Bool
    @State private var isSaving = false
    @State private var editingNote: UnsavedNote?
    @State private var isAddingNewNote = false
    @State private var selectedStudent: Student?
    @Binding var isShowingActivity: Bool
    @State private var editingActivity: UnsavedActivity?
    @State private var isAddingNewActivity = false
    @State private var showingSummaryError = false
    @State private var summaryErrorMessage = ""
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    @State private var isShowingDatePicker = false
    @State private var isShowingEditSheet = false
    @State private var showingSaveAlert = false
    @State private var activities: [Activity] = []
    @State private var progress: Double = 0.0
    @State private var progressTimer: Timer?
    
    
    init(
        selectedDate: Binding<Date>,
        viewModel: StudentTabViewModel,
        isShowingPreview: Binding<Bool>,
        isShowingActivity: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
        self._isShowingPreview = isShowingPreview
        self._isShowingActivity = isShowingActivity
    }
    
    
    var body: some View {
        ZStack {
            if !isSaving {
               
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(sortedStudents) { student in
                            DailyReportCardPreview(
                                student: student,
                                viewModel: viewModel,
                                selectedDate: selectedDate,
                                selectedStudent: $selectedStudent,
                                isAddingNewActivity: $isAddingNewActivity,
                                isAddingNewNote: $isAddingNewNote,
                                onDeleteActivity: { activity in
                                    viewModel.deleteUnsavedActivity(activity)
                                }, hasDefaultActivities: hasAnyDefaultActivity(for: student)
                            )
                            .padding(.bottom, 12)
                        }
                        
                        Button {
                            if hasStudentsWithNilActivities() {
                                showingSaveAlert = true
                            } else {
                                saveActivities()
                            }
                        } label: {
                            Text("Simpan")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.labelPrimaryBlack)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.orangeClickAble))
                                .cornerRadius(12)
                        }
                    }
                    
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .background(.bgMain)
                }
                .navigationBarItems(
                    leading: Button {
                        viewModel.clearUnsavedNotes()
                        viewModel.clearUnsavedActivities()
                        isShowingPreview = false
                    } label: {
                        HStack{
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.buttonLinkOnSheet)
                            Text("Pratinjau")
                                .foregroundStyle(.monochromeBlack)
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                    },
                    trailing: datePickerView().disabled(true)
                )
            }
            
            
           
            if isSaving {
                LoadingView(progress: progress)
            }
        }
        
        .toolbar(.hidden, for: .bottomBar , .tabBar )
        .hideTabBar()
        .navigationBarBackButtonHidden(true)
        .background(.bgMain)
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                AddUnsavedActivity(viewModel: viewModel,
                                       student: student,
                                       selectedDate: selectedDate,
                                       onDismiss: {
                    isAddingNewActivity = false
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
            }
        }
        .sheet(item: $editingNote) { note in
            EditUnsavedNote(note: note, onSave: { updatedNote in
                updateNote(updatedNote)
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        
        .sheet(isPresented: $isAddingNewNote) {
            if let student = selectedStudent {
                UnsavedNoteCreateView(student: student, onSave: { newNote in
                    addNewNote(newNote)
                }, selectedDate: selectedDate)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
            } else {
                Text("No student selected. Please try again.")
            }
        }
        .alert(isPresented: $showingSaveAlert) {
            Alert(
                title: Text("Konfirmasi"),
                message: Text("Masih ada murid yang aktivitasnya masih \"Tidak Melakukan\". Apa mau disimpan?"),
                primaryButton: .default(Text("Lanjut")) {
                    saveActivities()
                },
                secondaryButton: .cancel(Text("Batalkan"))
            )
        }
        .onDisappear {
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }
    
    private var sortedStudents: [Student] {
        viewModel.students.sorted { student1, student2 in
            let hasDefaultActivity1 = hasAnyDefaultActivity(for: student1)
            let hasDefaultActivity2 = hasAnyDefaultActivity(for: student2)
            
            if hasDefaultActivity1 != hasDefaultActivity2 {
                return hasDefaultActivity1
            }
            return student1.fullname < student2.fullname
        }
    }
    
    private func hasStudentsWithNilActivities() -> Bool {
        for student in viewModel.students {
            let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
            if studentActivities.contains(where: { $0.isIndependent == nil }) {
                return true
            }
        }
        return false
    }

    private func hasAnyDefaultActivity(for student: Student) -> Bool {
        let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
        return studentActivities.contains { activity in
            activity.isIndependent == nil
        }
    }
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func binding(for student: Student) -> [Binding<UnsavedActivity>] {
        viewModel.unsavedActivities
            .filter { $0.studentId == student.id }
            .map { activity in
                let index = viewModel.unsavedActivities.firstIndex { $0.id == activity.id }!
                return $viewModel.unsavedActivities[index]
            }
    }
    
    private func saveActivities() {
        isSaving = true
        progress = 0.0
        
        let duration = Double.random(in: 2...4)
        let stepTime = 0.1
        let stepValue = stepTime / duration
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: stepTime, repeats: true) { timer in
            withAnimation {
                if progress < 1.0 {
                    progress = min(progress + Double(stepValue), 1.0)
                }
            }
        }
        
        Task {
            do {
                for activity in viewModel.unsavedActivities {
                    if activity.isIndependent == nil {
                        activity.isIndependent = nil
                    }
                }
                
                await viewModel.saveUnsavedActivities()
                await viewModel.saveUnsavedNotes()
                try await viewModel.generateAndSaveSummaries(for: viewModel.selectedDate)
                
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                
                await MainActor.run {
                    progress = 1.0
                    progressTimer?.invalidate()
                    progressTimer = nil
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isSaving = false
                        isShowingPreview = false
                    }
                }
            } catch {
                await MainActor.run {
                    progressTimer?.invalidate()
                    progressTimer = nil
                    isSaving = false
                    showingSummaryError = true
                    summaryErrorMessage = "Failed to save data or generate summaries: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteUnsavedActivity(_ activity: UnsavedActivity) {
        viewModel.deleteUnsavedActivity(activity)
    }
    
    private func deleteNote(_ note: UnsavedNote) {
        viewModel.deleteUnsavedNote(note)
    }
    
    private func updateNote(_ updatedNote: UnsavedNote) {
        viewModel.updateUnsavedNote(updatedNote)
    }
    
    private func addNewNote(_ newNote: UnsavedNote) {
        viewModel.addUnsavedNote(newNote)
    }
    
    private func datePickerView() -> some View {
        Button(action: {
            isShowingDatePicker = true
        }) {
            HStack {
                Image(systemName: "calendar")
                Text(selectedDate, format: .dateTime.day().month().year())
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.buttonPrimaryLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Color(.orangeClickAble))
            .cornerRadius(8)
        }
    }
}
