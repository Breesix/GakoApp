//
//  NoteEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

struct NoteEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let note: Note
    let onDismiss: () -> Void
    @State private var noteText: String

    init(viewModel: StudentListViewModel, note: Note, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.note = note
        self.onDismiss = onDismiss
        _noteText = State(initialValue: note.note)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Catatan", text: $noteText)

                Button("Simpan Perubahan") {
                    saveNote()
                }
            }
            .navigationTitle("Edit Catatan")
            .navigationBarItems(trailing: Button("Tutup") {
                onDismiss()
            })
        }
    }

    private func saveNote() {
        note.note = noteText
        Task {
            await viewModel.updateNote(note)
            onDismiss()
        }
    }
}


