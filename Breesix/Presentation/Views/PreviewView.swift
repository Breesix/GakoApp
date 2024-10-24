//
//  PreviewView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct PreviewView: View {
    @ObservedObject var viewModel: StudentListViewModel
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
    @State private var activities: [Activity] = []
    let selectedDate: Date
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) { // Spacing between each student's section
                    ForEach(viewModel.students) { student in
                        let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
                        let studentNotes = viewModel.unsavedNotes.filter { $0.studentId == student.id }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            // Profile Header
                            ProfileHeaderPreview(student: student)
                                .padding(.bottom, 8)
                            
                            // Activity Section
                            if !studentActivities.isEmpty {
                                Section(header: Text("Aktivitas").font(.headline)) {
                                    ForEach(binding(for: student)) { activityBinding in
                                        let activity = activityBinding.wrappedValue
                                        
                                        ActivityDetailRow(
                                            activity: activityBinding,
                                            student: student,
                                            onAddActivity: {
                                                isAddingNewActivity = true
                                            },
                                            onDelete: {
                                                deleteUnsavedActivity(activity)
                                            }
                                        )
                                    }
                                    Button("Tambah", systemImage: "plus.app.fill", action: {
                                        selectedStudent = student
                                        isAddingNewNote = true
                                    })
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                Text("No activities for this student.")
                                    .italic()
                                    .foregroundColor(.gray)
                            }
                            
                            // Note Section
                            if !studentNotes.isEmpty {
                                Section(header: Text("Catatan").font(.headline)) {
                                    ForEach(studentNotes) { note in
                                        NoteRow(note: note, student: student, onEdit: {
                                            editingNote = note
                                        }, onDelete: {
                                            deleteNote(note)
                                        })
                                    }
                                    
                                    Button("Tambah", systemImage: "plus.app.fill", action: {
                                        selectedStudent = student
                                        isAddingNewActivity = true
                                    })
                                    .buttonStyle(.bordered)
                                }
                            } else {
                                Text("No notes for this student.")
                                    .italic()
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(16)
                        .background(Color.white) // Background for the entire section
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 0.5)
                        )
                        .padding(.horizontal) // Padding to give space from screen edges
                    }
                }
                .padding(.top) // Top padding to give some space from the top of the view
            }
            .navigationTitle("Preview")
            .navigationBarItems(
                leading: Button("Batal") {
                    viewModel.clearUnsavedNotes()
                    viewModel.clearUnsavedActivities()
                    isShowingPreview = false
                },
                trailing: Button("Simpan") {
                    saveActivities()
                }
                    .disabled(isSaving)
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
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                NewActivityView(viewModel: viewModel,
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
}





struct NoteRow: View {
    let note: UnsavedNote
    @State private var showDeleteAlert = false
    let student: Student
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack() {
            Text(note.note)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
            
            
            Button("Hapus", systemImage: "trash.fill", action: {
                showDeleteAlert = true // Show alert when button is pressed
            })
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .tint(.red)
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
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct UnsavedNoteEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var textNote: String
    let note: UnsavedNote
    let onSave: (UnsavedNote) -> Void
    
    init(note: UnsavedNote, onSave: @escaping (UnsavedNote) -> Void) {
        self.note = note
        self.onSave = onSave
        _textNote = State(initialValue: note.note)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Note", text: $textNote)
            }
            .navigationTitle("Edit Note")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let updatedNote = UnsavedNote(id: note.id, note: textNote, createdAt: note.createdAt, studentId: note.studentId)
                    onSave(updatedNote)
                    presentationMode.wrappedValue.dismiss()
                }
            )
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

