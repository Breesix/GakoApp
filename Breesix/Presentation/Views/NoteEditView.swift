//
//  ActivityEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

struct NoteEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let activity: Note
    let onDismiss: () -> Void
    @State private var note: String

    init(viewModel: StudentListViewModel, activity: Note, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.activity = activity
        self.onDismiss = onDismiss
        _note = State(initialValue: activity.note)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas Umum", text: $note)

                Button("Simpan Perubahan") {
                    saveActivity()
                }
            }
            .navigationTitle("Edit Catatan")
            .navigationBarItems(trailing: Button("Tutup") {
                onDismiss()
            })
        }
    }

    private func saveActivity() {
        activity.note = note
        Task {
            await viewModel.updateActivity(activity)
            onDismiss()
        }
    }
}


