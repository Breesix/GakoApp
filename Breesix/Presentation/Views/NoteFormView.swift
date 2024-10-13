//
//  NoteFormView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI

struct NoteFormView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Binding var isPresented: Bool
    @State private var selectedStudent: Student?
    @State private var note = ""
    @State private var toiletTraining = ""
    @State private var toiletTrainingStatus = false

    var body: some View {
        NavigationView {
            Form {
                Picker("Pilih Murid", selection: $selectedStudent) {
                    ForEach(viewModel.students, id: \.id) { student in
                        Text(student.fullname).tag(student as Student?)
                    }
                }

                TextField("Catatan", text: $note)
                TextField("Catatan Toilet Training", text: $toiletTraining)
                Toggle("Status Toilet Training", isOn: $toiletTrainingStatus)

                Button("Simpan Catatan") {
                    saveNote()
                }
            }
            .navigationTitle("Tambah Catatan")
            .navigationBarItems(trailing: Button("Tutup") {
                isPresented = false
            })
        }
    }

    private func saveNote() {
        guard let student = selectedStudent else { return }
        let newNote = Note(note: note)
        Task {
            await viewModel.addNote(newNote, for: student)
            isPresented = false
        }
    }
}
