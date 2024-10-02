//
//  ActivityFormView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI

struct ActivityFormView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Binding var isPresented: Bool
    @State private var selectedStudent: Student?
    @State private var generalActivity = ""
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

                TextField("Aktivitas Umum", text: $generalActivity)
                TextField("Catatan Toilet Training", text: $toiletTraining)
                Toggle("Status Toilet Training", isOn: $toiletTrainingStatus)

                Button("Simpan Catatan") {
                    saveActivity()
                }
            }
            .navigationTitle("Tambah Catatan")
            .navigationBarItems(trailing: Button("Tutup") {
                isPresented = false
            })
        }
    }

    private func saveActivity() {
        guard let student = selectedStudent else { return }
        let newActivity = Activity(generalActivity: generalActivity)
        Task {
            await viewModel.addActivity(newActivity, for: student)
            isPresented = false
        }
    }
}
