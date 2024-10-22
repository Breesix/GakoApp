//
//  NewActivityView.swift
//  Breesix
//
//  Created by Rangga Biner on 13/10/24.
//

import SwiftUI

struct NewActivityView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    @State private var activityText: String = ""
    @State private var status: Bool = false


    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas", text: $activityText)
                Toggle("Mandiri", isOn: $status)

                Button("Simpan Perubahan") {
                    saveNewActivity()
                }
            }
            .navigationTitle("Aktivitas Baru")
            .navigationBarItems(trailing: Button("Tutup") {
                onDismiss()
            })
        }
    }

    private func saveNewActivity() {
        let newActivity = Activity(activity: activityText, createdAt: selectedDate, isIndependent: status, student: student)
        Task {
            await viewModel.addActivity(newActivity, for: student)
            onDismiss()
        }
    }

}


