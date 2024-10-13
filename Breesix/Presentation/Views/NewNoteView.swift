//
//  NewNoteView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.
//

import SwiftUI

struct NewNoteView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    @State private var note: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Catatan", text: $note)

                Button("Simpan Catatan") {
                    saveNewNote()
                }
            }
            .navigationTitle("Catatan Baru")
            .navigationBarItems(trailing: Button("Batal") {
                onDismiss()
            })
        }
    }

    private func saveNewNote() {
        let newNote = Note(note: note, createdAt: selectedDate, student: student)
        Task {
            await viewModel.addNote(newNote, for: student)
            onDismiss()
        }
    }
}
