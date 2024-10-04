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
    @State private var generalActivity: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas Umum", text: $generalActivity)

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
        let newActivity = Activity(generalActivity: generalActivity, createdAt: selectedDate, student: student)
        Task {
            await viewModel.addActivity(newActivity, for: student)
            onDismiss()
        }
    }
}
