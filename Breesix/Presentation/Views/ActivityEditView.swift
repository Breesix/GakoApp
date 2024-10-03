//
//  ActivityEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

struct ActivityEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let activity: Activity
    let onDismiss: () -> Void
    @State private var generalActivity: String

    init(viewModel: StudentListViewModel, activity: Activity, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.activity = activity
        self.onDismiss = onDismiss
        _generalActivity = State(initialValue: activity.generalActivity)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas Umum", text: $generalActivity)

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
        activity.generalActivity = generalActivity
        Task {
            await viewModel.updateActivity(activity)
            onDismiss()
        }
    }
}


