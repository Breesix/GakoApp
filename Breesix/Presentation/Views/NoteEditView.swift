//
//  NoteEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct NoteEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let note: Activity
    let onDismiss: () -> Void
    @State private var generalActivity: String

    init(viewModel: StudentListViewModel, note: Activity, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.note = note
        self.onDismiss = onDismiss
        _generalActivity = State(initialValue: note.generalActivity)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas Umum", text: $generalActivity)

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
        note.generalActivity = generalActivity
        Task {
            await viewModel.updateActivity(note)
            onDismiss()
        }
    }
}
