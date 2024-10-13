//
//  NewActivityView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.
//

import SwiftUI

struct NewActivityView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    @State private var note: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas Umum", text: $note)

                Button("Simpan Aktivitas") {
                    saveNewActivity()
                }
            }
            .navigationTitle("Tambah Aktivitas Baru")
            .navigationBarItems(trailing: Button("Batal") {
                onDismiss()
            })
        }
    }

    private func saveNewActivity() {
        let newActivity = Note(note: note, createdAt: selectedDate, student: student)
        Task {
            await viewModel.addNote(newActivity, for: student)
            onDismiss()
        }
    }
}
