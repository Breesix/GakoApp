//
//  ActivityEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.
//

import SwiftUI

struct ActivityEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let activity: Activity
    let onDismiss: () -> Void
    @State private var activityText: String
    @State private var status: Bool

    init(viewModel: StudentListViewModel, activity: Activity, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.activity = activity
        self.onDismiss = onDismiss
        _activityText = State(initialValue: activity.activity)
        _status = State(initialValue: activity.isIndependent!)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Catatan", text: $activityText)
                Toggle("Mandiri", isOn: $status)

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
        activity.activity = activityText
        activity.isIndependent = status
        Task {
            await viewModel.updateActivity(activity)
            onDismiss()
        }
    }
}


