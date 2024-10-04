//
//  TrainingEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.
//

import SwiftUI

struct TrainingEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let training: ToiletTraining
    let onDismiss: () -> Void
    @State private var trainingDetail: String

    init(viewModel: StudentListViewModel, training: ToiletTraining, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.training = training
        self.onDismiss = onDismiss
        _trainingDetail = State(initialValue: training.trainingDetail)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Aktivitas Umum", text: $trainingDetail)

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
        training.trainingDetail = trainingDetail
        Task {
            await viewModel.updateTraining(training)
            onDismiss()
        }
    }
}


