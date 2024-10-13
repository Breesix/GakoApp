//
//  TrainingEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.
//

import SwiftUI

struct TrainingEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let training: Activity
    let onDismiss: () -> Void
    @State private var trainingDetail: String
    @State private var status: Bool

    init(viewModel: StudentListViewModel, training: Activity, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.training = training
        self.onDismiss = onDismiss
        _trainingDetail = State(initialValue: training.activity)
        _status = State(initialValue: training.isIndependent!)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Catatan", text: $trainingDetail)
                Toggle("Mandiri", isOn: $status)

                Button("Simpan Perubahan") {
                    saveTraining()
                }
            }
            .navigationTitle("Edit Catatan")
            .navigationBarItems(trailing: Button("Tutup") {
                onDismiss()
            })
        }
    }

    private func saveTraining() {
        training.activity = trainingDetail
        training.isIndependent = status
        Task {
            await viewModel.updateTraining(training)
            onDismiss()
        }
    }
}


