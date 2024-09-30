//
//  NoteEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct NoteEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let note: Note
    let onDismiss: () -> Void
    @State private var generalActivity: String
    @State private var toiletTraining: String
    @State private var toiletTrainingStatus: Bool

    init(viewModel: StudentListViewModel, note: Note, onDismiss: @escaping () -> Void) {
        print("Initializing NoteEditView for note: \(note.id)")
        self.viewModel = viewModel
        self.note = note
        self.onDismiss = onDismiss
        _generalActivity = State(initialValue: note.generalActivity)
        _toiletTraining = State(initialValue: note.toiletTraining)
        _toiletTrainingStatus = State(initialValue: note.toiletTrainingStatus)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas Umum", text: $generalActivity)
                TextField("Catatan Toilet Training", text: $toiletTraining)
                Toggle("Status Toilet Training", isOn: $toiletTrainingStatus)

                Button("Simpan Perubahan") {
                    saveNote()
                }
            }
            .navigationTitle("Edit Catatan")
            .navigationBarItems(trailing: Button("Tutup") {
                onDismiss()
            })
        }
        .onAppear {
            print("NoteEditView appeared")
        }
        .onDisappear {
            print("NoteEditView disappeared")
        }
    }

    private func saveNote() {
        note.generalActivity = generalActivity
        note.toiletTraining = toiletTraining
        note.toiletTrainingStatus = toiletTrainingStatus
        Task {
            await viewModel.updateNote(note)
            onDismiss()
        }
    }
}
