//
//  ReflectionPreviewView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct ReflectionPreviewView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowingPreview: Bool
    @State private var isSaving = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
                    if !studentActivities.isEmpty {
                        Section(header: Text(student.fullname)) {
                            ForEach(studentActivities) { activity in
                                VStack(alignment: .leading) {
                                    Text(activity.generalActivity)
                                    Text("Tanggal: \(activity.createdAt, formatter: itemFormatter)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Preview Refleksi")
            .navigationBarItems(
                leading: Button("Batal") {
                    viewModel.clearUnsavedActivities()
                    isShowingPreview = false
                },
                trailing: Button("Simpan") {
                    saveActivities()
                }
                .disabled(isSaving)
            )
        }
        .overlay(
            Group {
                if isSaving {
                    ProgressView("Menyimpan...")
                        .padding()
                        .background(Color.secondary.colorInvert())
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
        )
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func saveActivities() {
        isSaving = true
        Task {
            await viewModel.saveUnsavedActivities()
            await MainActor.run {
                isSaving = false
                isShowingPreview = false
            }
        }
    }
}
