//
//  TrainingPreviewView.swift
//  Breesix
//
//  Created by Akmal Hakim on 03/10/24.
//

import SwiftUI

struct TrainingPreviewView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowingToiletTraining: Bool
    @State private var isSaving = false
    @State private var editingTraining: UnsavedToiletTraining?
    @State private var isAddingNewTraining = false
    @State private var selectedStudent: Student?

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    let studentTrainings = viewModel.unsavedToiletTrainings.filter { $0.studentId == student.id }
                    if !studentTrainings.isEmpty {
                        Section(header: Text(student.fullname)) {
                            ForEach(studentTrainings) { training in
                                TrainingDetailRow(toiletTraining: training, student: student, onEdit: {
                                    editingTraining = training
                                }, onDelete: {
                                    deleteTraining(training)
                                })
                            }
                        }
                    }
                }
            }
            .navigationTitle("Preview Toilet Training")
            .navigationBarItems(
                leading: Button("Cancel") {
                    viewModel.clearUnsavedToiletTrainings()
                    isShowingToiletTraining = false
                },
                trailing: Button("Save") {
                    saveTrainings()
                }
                .disabled(isSaving)
            )
            .overlay(
                Group {
                    if isSaving {
                        ProgressView("Saving...")
                            .padding()
                            .background(Color.secondary.colorInvert())
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                }
            )
        }
        .sheet(item: $editingTraining) { training in
            UnsavedTrainingEditView(training: training, onSave: { updatedTraining in
                updateTraining(updatedTraining)
            })
        }
//        .sheet(isPresented: $isAddingNewTraining) {
//            if let student = selectedStudent {
//                TrainingCreateView(student: student, onSave: { newTraining in
////                    addNewTraining(newTraining)
//                })
//            } else {
//                Text("No student selected. Please try again.")
//            }
//        }
    }

    private func saveTrainings() {
        isSaving = true
        Task {
            // Implement the logic to save toilet trainings
            // You might need to add a method in your ViewModel to handle this
            await viewModel.saveUnsavedToiletTrainings()
            await MainActor.run {
                isSaving = false
                isShowingToiletTraining = false
            }
        }
    }
    
    private func deleteTraining(_ training: UnsavedToiletTraining) {
        viewModel.deleteUnsavedToiletTraining(training)
    }
    
    private func updateTraining(_ updatedTraining: UnsavedToiletTraining) {
        viewModel.updateUnsavedToiletTraining(updatedTraining)
    }
//    
//    private func addNewTraining(_ newTraining: ToiletTraining) {
//        viewModel.toiletTrainings.append(newTraining)
//    }
}

struct TrainingDetailRow: View {
    let toiletTraining: UnsavedToiletTraining
    let student: Student
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Toilet Training")
            if toiletTraining.status! {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Independent")
                }
                .foregroundColor(.green)
            } else {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("Needs Guidance")
                }
                .foregroundColor(.red)
            }
            Text("Date: \(toiletTraining.createdAt, formatter: itemFormatter)")
            Text(toiletTraining.trainingDetail)
        }
        .contextMenu {
            Button("Edit", action: onEdit)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

struct UnsavedTrainingEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var trainingDetail: String
    @State private var status: Bool
    let training: UnsavedToiletTraining
    let onSave: (UnsavedToiletTraining) -> Void
    
    init(training: UnsavedToiletTraining, onSave: @escaping (UnsavedToiletTraining) -> Void) {
        self.training = training
        self.onSave = onSave
        _trainingDetail = State(initialValue: training.trainingDetail)
        _status = State(initialValue: training.status!)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Training Detail", text: $trainingDetail)
                Toggle("Independent", isOn: $status)
            }
            .navigationTitle("Edit Training")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let updatedTraining = UnsavedToiletTraining(id: training.id, trainingDetail: trainingDetail, createdAt: training.createdAt, status: status, studentId: training.studentId)
                    onSave(updatedTraining)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

//struct TrainingCreateView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var trainingDetail: String = ""
//    @State private var status: Bool = false
//    let student: Student
//    let onSave: (ToiletTraining) -> Void
//
//    var body: some View {
//        NavigationView {
//            Form {
//                TextField("Training Detail", text: $trainingDetail)
//                Toggle("Independent", isOn: $status)
//            }
//            .navigationTitle("New Training")
//            .navigationBarItems(
//                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
//                trailing: Button("Save") {
//                    let newTraining = ToiletTraining(trainingDetail: trainingDetail, createdAt: Date(), status: status, student: student)
//                    onSave(newTraining)
//                    presentationMode.wrappedValue.dismiss()
//                }
//            )
//        }
//    }
//}

//import SwiftUI
//
//struct TrainingPreviewView: View {
//    @ObservedObject var viewModel: StudentListViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var isShowingPreview: Bool
//    @State private var isSaving = false
//    @State private var training: ToiletTraining?
//    @State private var isAddingNewActivity = false
//    @State private var selectedStudent: Student?
//    var body: some View {
//        NavigationView {
//            ForEach(viewModel.students) { student in
//                let toiletTrainingEach = viewModel.toiletTrainings.filter {
//                    $0.student == student }
//                
//                Section(header: Text(student.fullname)) {
//                    
//                }
//            }
//            
//        }
//    }
//}
//
//struct TrainingDetailRow: View {
//    let toiletTraining: ToiletTraining
//    let student: Student
////    let onEdit: () -> Void
////    let onDelete: () -> Void
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("Toilet Training")
//            if toiletTraining.status {
//                HStack {
//                    Image(systemName: "checkmark.circle.fill")
//                    Text("Mandiri")
//                }
//                .background(Color.green)
//            }
//            else {
//                HStack {
//                    Image(systemName: "xmark.circle.fill")
//                    Text("Dibimbing")
//                }
//                .background(Color.red)
//            }
//            Text("Tanggal: \(toiletTraining.createdAt, formatter: itemFormatter)")
//        }
////        .contextMenu {
////            Button("Edit", action: onEdit)
////            Button("Delete", role: .destructive, action: onDelete)
////        }
//    }
//    
//    private let itemFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        return formatter
//    }()
//    
//}
