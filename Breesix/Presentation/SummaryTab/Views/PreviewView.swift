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
    @State private var activities: [Activity] = []
    
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
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.students) { student in
                    StudentSectionView(
                        student: student,
                        viewModel: viewModel,
                        selectedDate: selectedDate,
                        selectedStudent: $selectedStudent,
                        isAddingNewActivity: $isAddingNewActivity,
                        isAddingNewNote: $isAddingNewNote,
                        onDeleteActivity: { activity in
                            viewModel.deleteUnsavedActivity(activity)
                        }
                        
                    )
                    .padding(.bottom, 12)
                }
                
                Button {
                    saveActivities()
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
            .toolbarBackground(Color(.bgMain), for: .navigationBar)
            .background(.bgMain)
            .hideTabBar()
            .navigationBarBackButtonHidden(true)
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
            .overlay(
                Group {
                    if isSaving {
                        ProgressView("Menyimpan...")
                            .padding()
                            .background(Color.secondary.colorInvert())
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                }
            )
        }
        .background(.bgMain)
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                NewUnsavedActivityView(viewModel: viewModel,
                                       student: student,
                                       selectedDate: selectedDate,
                                       onDismiss: {
                    isAddingNewActivity = false
                })
            }
        }
        .sheet(item: $editingNote) { note in
            UnsavedNoteEditView(note: note, onSave: { updatedNote in
                updateNote(updatedNote)
            })
        }
        
        .sheet(isPresented: $isAddingNewNote) {
            if let student = selectedStudent {
                UnsavedNoteCreateView(student: student, onSave: { newNote in
                    addNewNote(newNote)
                }, selectedDate: selectedDate)
            } else {
                Text("No student selected. Please try again.")
            }
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
        Task {
            do {
                try await viewModel.saveUnsavedActivities()
                try await viewModel.saveUnsavedNotes()
                try await viewModel.generateAndSaveSummaries(for: viewModel.selectedDate)
                await MainActor.run {
                    isSaving = false
                    isShowingPreview = false
                }
            } catch {
                await MainActor.run {
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

struct NoteRow: View {
    let note: UnsavedNote
    let student: Student
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 8) {
            Text(note.note)
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundStyle(.labelPrimaryBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.monochrome100)
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.noteStroke, lineWidth: 0.5)
                }
                .contextMenu {
                    Button("Edit") { onEdit() }
                }
            Button(action: {
                showDeleteAlert = true
            }) {
                Image("custom.trash.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34)
            }
            .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                Button("Hapus", role: .destructive) {
                    onDelete()
                }
                Button("Batal", role: .cancel) { }
            } message: {
                Text("Apakah kamu yakin ingin menghapus catatan ini?")
            }
        }
    }
}

struct UnsavedNoteEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var textNote: String
    let note: UnsavedNote
    let onSave: (UnsavedNote) -> Void
    
    init(note: UnsavedNote, onSave: @escaping (UnsavedNote) -> Void) {
        self.note = note
        self.onSave = onSave
        _textNote = State(initialValue: note.note)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Catatan", text: $textNote)
                    .textFieldStyle(.roundedBorder)
                    .padding(.vertical, 8)
            }
            .navigationTitle("Edit Catatan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Batal") {
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        let updatedNote = UnsavedNote(
                            id: note.id,
                            note: textNote,
                            createdAt: note.createdAt,
                            studentId: note.studentId
                        )
                        onSave(updatedNote)
                        dismiss()
                    }
                    .disabled(textNote.isEmpty)
                }
            }
        }
    }
}

struct UnsavedNoteCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var textNote: String = ""
    let student: Student
    let onSave: (UnsavedNote) -> Void
    
    let selectedDate: Date
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Note", text: $textNote)
            }
            .navigationTitle("New Note")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let newNote = UnsavedNote(note: textNote, createdAt: selectedDate, studentId: student.id)
                    onSave(newNote)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            print("NoteCreateView appeared for student: \(student.fullname)")
        }
    }
}

