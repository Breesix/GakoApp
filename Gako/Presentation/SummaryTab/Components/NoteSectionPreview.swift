//  NoteSectionPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct NoteSectionPreview: View {
    let student: Student
    let notes: [UnsavedNote]
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewNote: Bool
    let selectedDate: Date
    @State private var editingNote: UnsavedNote?
    
    let onUpdateNote: (UnsavedNote) -> Void
    let onDeleteNote: (UnsavedNote) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
        Text("CATATAN")
            .foregroundStyle(.labelPrimaryBlack)
            .font(.callout)
            .fontWeight(.semibold)
            .padding(.bottom, 16)
        
        let studentNotes = notes.filter { $0.studentId == student.id }
        
        if !studentNotes.isEmpty {
            ForEach(studentNotes) { note in
                NoteRowPreview(note: note, onEdit: { note in
                    editingNote = note
                }, onDelete: { note in
                    onDeleteNote(note)
                })
                .padding(.bottom, 12)
            }
            
            .sheet(item: $editingNote) { note in
                ManageUnsavedNoteView(
                    mode: .edit(note),
                    onSave: { updatedNote in
                        onUpdateNote(updatedNote)
                        editingNote = nil
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
            }
        } else {
            Text("Tidak ada catatan untuk tanggal ini")
                .foregroundColor(.labelSecondaryBlack)
                .padding(.bottom, 12)
        }
        
        AddItemButton(
            onTapAction: {
                selectedStudent = student
                isAddingNewNote = true
            },
            bgColor: .buttonOncard, text: "Tambah"
        )
    }
}

}

#Preview {
    NoteSectionPreview(
        student: Student(
            id: UUID(),
            fullname: "Rangga Biner",
            nickname: "Rangga"
        ),
        notes: [
            UnsavedNote(
                id: UUID(),
                note: "First sample note content",
                createdAt: Date(),
                studentId: UUID()
            ),
            UnsavedNote(
                id: UUID(),
                note: "Second sample note content",
                createdAt: Date().addingTimeInterval(-86400),
                studentId: UUID()
            )
        ],
        selectedStudent: .constant(nil),
        isAddingNewNote: .constant(false),
        selectedDate: Date(),
        onUpdateNote: { _ in },
        onDeleteNote: { _ in }
    )
}
