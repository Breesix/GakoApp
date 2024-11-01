//
//  NoteSectionPreview.swift
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
            Section(header: Text("Catatan").font(.callout).padding(.bottom, 8).fontWeight(.semibold).foregroundStyle(.labelPrimaryBlack)) {
                ForEach(studentNotes) { note in
                    NoteRowPreview(
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
                
                
            }
            .sheet(item: $editingNote) { note in
                EditUnsavedNote(note: note) { updatedNote in
                    viewModel.updateUnsavedNote(updatedNote)
                    editingNote = nil
                }
            }
        } else {
            Text("Tidak ada aktivitas untuk tanggal ini")
                .foregroundColor(.labelSecondary)
        }

        AddButton(
            action: { selectedStudent = student
                isAddingNewNote = true
            },
            backgroundColor: .buttonOncard
        )

    }
}

