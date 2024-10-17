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
    
    let selectedDate: Date

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
                    if !studentActivities.isEmpty {
                        Section(header: Text(student.fullname)) {
                            ForEach(studentActivities) { activity in
                                ActivityDetailRow(activity: activity, student: student, onEdit: {
                                    editingActivity = activity
                                }, onDelete: {
                                    deleteUnsavedActivity(activity)
                                })
                            }
                        }
                    }
                }
                ForEach(viewModel.students) { student in
                    let studentNotes = viewModel.unsavedNotes.filter { $0.studentId == student.id }
                    if !studentNotes.isEmpty {
                        Section(header: Text(student.fullname)) {
                            ForEach(studentNotes) { note in
                                NoteRow(note: note, student: student, onEdit: {
                                    editingNote = note
                                }, onDelete: {
                                    deleteNote(note)
                                })
                            }
                            
                            Button("Add New Note") {
                                selectedStudent = student
                                isAddingNewNote = true
                            }
                            .onChange(of: selectedStudent) { oldValue, newValue in
                                if newValue != nil {
                                    isAddingNewNote = true
                                }
                            }

                        }
                    }
                }
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
//                    saveNotes()
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
    
    private func saveNotes() {
        isSaving = true
        Task {
            await viewModel.saveUnsavedNotes()
            await MainActor.run {
                isSaving = false
                isShowingPreview = false
            }
        }
    }
    
    private func saveActivities() {
        isSaving = true
        Task {
            await viewModel.saveUnsavedActivities()
            await viewModel.saveUnsavedNotes()
            await MainActor.run {
                isSaving = false
                isShowingPreview = false
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
    let student: Student
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(note.note)
            Text("Tanggal: \(note.createdAt, formatter: itemFormatter)")
        }
        .contextMenu {
            Button("Edit", action: onEdit)
            Button("Delete", role: .destructive, action: onDelete)
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

