//
//  NoteSectionView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct NoteSectionPreview: View {
    let student: Student
    @ObservedObject var viewModel: StudentTabViewModel
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewNote: Bool
    let selectedDate: Date
    @State private var editingNote: UnsavedNote?
    
    var body: some View {
        let studentNotes = viewModel.unsavedNotes.filter { $0.studentId == student.id }
        
        if !studentNotes.isEmpty {
            Section(header: Text("Catatan").font(.callout).padding(.bottom, 8).fontWeight(.semibold)) {
                ForEach(studentNotes) { note in
                    NoteRow(
                        note: note,
                        student: student,
                        onEdit: {
                            editingNote = note
                        },
                        onDelete: {
                            viewModel.deleteUnsavedNote(note)
                        }
                    )
                    .padding(.bottom, 12)
                }
                
                AddButton {
                    selectedStudent = student
                    isAddingNewNote = true
                }
            }
            .sheet(item: $editingNote) { note in
                UnsavedNoteEditView(note: note) { updatedNote in
                    viewModel.updateUnsavedNote(updatedNote)
                    editingNote = nil
                }
            }
        } else {
            Text("No notes for this student.")
                .italic()
                .foregroundColor(.gray)
        }
    }
}

