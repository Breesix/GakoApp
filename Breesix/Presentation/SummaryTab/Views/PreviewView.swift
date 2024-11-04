//
//  PreviewView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct PreviewView: View {
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
    
    // Data properties
    private let students: [Student]
    private var unsavedActivities: [UnsavedActivity]
    private var unsavedNotes: [UnsavedNote]
    
    // Callback functions
    let onAddUnsavedActivities: ([UnsavedActivity]) -> Void
    let onUpdateUnsavedActivity: (UnsavedActivity) -> Void
    let onDeleteUnsavedActivity: (UnsavedActivity) -> Void
    let onAddUnsavedNote: (UnsavedNote) -> Void
    let onUpdateUnsavedNote: (UnsavedNote) -> Void
    let onDeleteUnsavedNote: (UnsavedNote) -> Void
    let onClearUnsavedNotes: () -> Void
    let onClearUnsavedActivities: () -> Void
    let onSaveUnsavedActivities: () async -> Void
    let onSaveUnsavedNotes: () async -> Void
    let onGenerateAndSaveSummaries: (Date) async throws -> Void
    
    init(
        selectedDate: Binding<Date>,
        isShowingPreview: Binding<Bool>,
        isShowingActivity: Binding<Bool>,
        students: [Student],
        unsavedActivities: [UnsavedActivity],
        unsavedNotes: [UnsavedNote],
        onAddUnsavedActivities: @escaping ([UnsavedActivity]) -> Void,
        onUpdateUnsavedActivity: @escaping (UnsavedActivity) -> Void,
        onDeleteUnsavedActivity: @escaping (UnsavedActivity) -> Void,
        onAddUnsavedNote: @escaping (UnsavedNote) -> Void,
        onUpdateUnsavedNote: @escaping (UnsavedNote) -> Void,
        onDeleteUnsavedNote: @escaping (UnsavedNote) -> Void,
        onClearUnsavedNotes: @escaping () -> Void,
        onClearUnsavedActivities: @escaping () -> Void,
        onSaveUnsavedActivities: @escaping () async -> Void,
        onSaveUnsavedNotes: @escaping () async -> Void,
        onGenerateAndSaveSummaries: @escaping (Date) async throws -> Void
    ) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
        self._isShowingPreview = isShowingPreview
        self._isShowingActivity = isShowingActivity
        self.students = students
        self.unsavedActivities = unsavedActivities
        self.unsavedNotes = unsavedNotes
        self.onAddUnsavedActivities = onAddUnsavedActivities
        self.onUpdateUnsavedActivity = onUpdateUnsavedActivity
        self.onDeleteUnsavedActivity = onDeleteUnsavedActivity
        self.onAddUnsavedNote = onAddUnsavedNote
        self.onUpdateUnsavedNote = onUpdateUnsavedNote
        self.onDeleteUnsavedNote = onDeleteUnsavedNote
        self.onClearUnsavedNotes = onClearUnsavedNotes
        self.onClearUnsavedActivities = onClearUnsavedActivities
        self.onSaveUnsavedActivities = onSaveUnsavedActivities
        self.onSaveUnsavedNotes = onSaveUnsavedNotes
        self.onGenerateAndSaveSummaries = onGenerateAndSaveSummaries
    }
    
    var body: some View {
        ZStack {
            if !isSaving {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(sortedStudents) { student in
                            DailyReportCardPreview(
                                student: student,
                                selectedDate: selectedDate,
                                selectedStudent: $selectedStudent,
                                isAddingNewActivity: $isAddingNewActivity,
                                isAddingNewNote: $isAddingNewNote,
                                hasDefaultActivities: hasAnyDefaultActivity(for: student),
                                onUpdateActivity: { updatedActivity in
                                    onUpdateUnsavedActivity(updatedActivity)
                                },
                                onDeleteActivity: { activity in
                                    onDeleteUnsavedActivity(activity)
                                },
                                onUpdateNote: { updatedNote in
                                    onUpdateUnsavedNote(updatedNote)
                                },
                                onDeleteNote: { note in
                                    onDeleteUnsavedNote(note)
                                },
                                activities: unsavedActivities.filter { $0.studentId == student.id },
                                notes: unsavedNotes.filter { $0.studentId == student.id }
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
                        onClearUnsavedNotes()
                        onClearUnsavedActivities()
                        isShowingPreview = false
                    } label: {
                        HStack {
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
        .toolbar(.hidden, for: .bottomBar, .tabBar)
        .hideTabBar()
        .navigationBarBackButtonHidden(true)
        .background(.bgMain)
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                AddUnsavedActivityView(
                    student: student,
                    selectedDate: selectedDate,
                    onDismiss: { isAddingNewActivity = false },
                    onSaveActivity: { newActivity in
                        Task {
                            onAddUnsavedActivities([newActivity])
                        }
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
            }
        }
        .sheet(isPresented: $isAddingNewNote) {
            if let student = selectedStudent {
                ManageUnsavedNoteView(
                    mode: .add(student, selectedDate),
                    onSave: { newNote in
                        addNewNote(newNote)
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
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
//            progressTimer?.invalidate()
//            progressTimer = nil
            if let timer = progressTimer {
                timer.invalidate()
            }
            progressTimer = nil

        }
    }
    
    private var sortedStudents: [Student] {
        students.sorted { student1, student2 in
            let hasDefaultActivity1 = hasAnyDefaultActivity(for: student1)
            let hasDefaultActivity2 = hasAnyDefaultActivity(for: student2)
            if hasDefaultActivity1 != hasDefaultActivity2 {
                return hasDefaultActivity1
            }
            return student1.fullname < student2.fullname
        }
    }
    
    private func hasStudentsWithNilActivities() -> Bool {
        for student in students {
            let studentActivities = unsavedActivities.filter { $0.studentId == student.id }
            if studentActivities.contains(where: { $0.status == .tidakMelakukan }) {
                return true
            }
        }
        return false
    }
    
    private func hasAnyDefaultActivity(for student: Student) -> Bool {
        let studentActivities = unsavedActivities.filter { $0.studentId == student.id }
        return studentActivities.contains { activity in
            activity.status == .tidakMelakukan
        }
    }
    
    private func saveActivities() {
        Task {
            await MainActor.run {
                isSaving = true
                progress = 0.0
            }
            
            do {
                await onSaveUnsavedActivities()
                await onSaveUnsavedNotes()
                try await onGenerateAndSaveSummaries(selectedDate)
                
                let duration = Double.random(in: 2...4)
                let steps = Int(duration / 0.1)
                
                for _ in 0..<steps {
                    try await Task.sleep(nanoseconds: UInt64(0.1 * 1_000_000_000))
                    await MainActor.run {
                        withAnimation {
                            progress = min(progress + (1.0 / Double(steps)), 1.0)
                        }
                    }
                }
                
                await MainActor.run {
                    progress = 1.0
                    isSaving = false
                    isShowingPreview = false
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    showingSummaryError = true
                    summaryErrorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func addNewNote(_ newNote: UnsavedNote) {
        onAddUnsavedNote(newNote)
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

#Preview {
    PreviewView(
        selectedDate: .constant(.now),
        isShowingPreview: .constant(false),
        isShowingActivity: .constant(false),
        students: [
            .init(fullname: "Rangga Biner", nickname: "Rangga")
        ],
        unsavedActivities: [
            .init(activity: "Menjahit", createdAt: .now, studentId: UUID())
        ],
        unsavedNotes: [
            .init(note: "baik banget", createdAt: .now, studentId: UUID())
        ],
        onAddUnsavedActivities: { _ in print("added") },
        onUpdateUnsavedActivity: { _ in print("updated") },
        onDeleteUnsavedActivity: { _ in print("deleted") },
        onAddUnsavedNote: { _ in print("added") },
        onUpdateUnsavedNote: { _ in print("updated") },
        onDeleteUnsavedNote: { _ in print("deleted") },
        onClearUnsavedNotes: { print("cleared") },
        onClearUnsavedActivities: { print("cleared") },
        onSaveUnsavedActivities: { print("saved") },
        onSaveUnsavedNotes: { print("saved") },
        onGenerateAndSaveSummaries: { _ in print("generated and saved") }
    )
}
