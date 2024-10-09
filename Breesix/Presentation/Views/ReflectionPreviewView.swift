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
    @State private var editingActivity: UnsavedActivity?
    @State private var isAddingNewActivity = false
    @State private var selectedStudent: Student?
    @Binding var isShowingToiletTraining: Bool
    @State private var editingTraining: UnsavedToiletTraining?
    @State private var isAddingNewTraining = false
    
    let selectedDate: Date

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
                ForEach(viewModel.students) { student in
                    let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
                    if !studentActivities.isEmpty {
                        Section(header: Text(student.fullname)) {
                            ForEach(studentActivities) { activity in
                                ActivityRow(activity: activity, student: student, onEdit: {
                                    editingActivity = activity
                                }, onDelete: {
                                    deleteActivity(activity)
                                })
                            }
                            
                            Button("Add New Activity") {
                                selectedStudent = student
                                isAddingNewActivity = true
                            }
                            .onChange(of: selectedStudent) { oldValue, newValue in
                                if newValue != nil {
                                    isAddingNewActivity = true
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
                    viewModel.clearUnsavedToiletTrainings()
                    isShowingPreview = false
                },
                trailing: Button("Simpan") {
                    saveActivities()
                    saveTrainings()
                }
                .disabled(isSaving)
            )
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
        .sheet(item: $editingActivity) { activity in
            UnsavedActivityEditView(activity: activity, onSave: { updatedActivity in
                updateActivity(updatedActivity)
            })
        }
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                UnsavedActivityCreateView(student: student, onSave: { newActivity in
                    addNewActivity(newActivity)
                }, selectedDate: selectedDate)
            } else {
                Text("No student selected. Please try again.")
            }
        }
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
    
    private func deleteActivity(_ activity: UnsavedActivity) {
        viewModel.deleteUnsavedActivity(activity)
    }
    
    private func updateActivity(_ updatedActivity: UnsavedActivity) {
        viewModel.updateUnsavedActivity(updatedActivity)
    }
    
    private func addNewActivity(_ newActivity: UnsavedActivity) {
        viewModel.addUnsavedActivity(newActivity)
    }
}

struct ActivityRow: View {
    let activity: UnsavedActivity
    let student: Student
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(activity.generalActivity)
            Text("Tanggal: \(activity.createdAt, formatter: itemFormatter)")
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

struct UnsavedActivityEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var generalActivity: String
    let activity: UnsavedActivity
    let onSave: (UnsavedActivity) -> Void
    
    init(activity: UnsavedActivity, onSave: @escaping (UnsavedActivity) -> Void) {
        self.activity = activity
        self.onSave = onSave
        _generalActivity = State(initialValue: activity.generalActivity)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Activity", text: $generalActivity)
            }
            .navigationTitle("Edit Activity")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let updatedActivity = UnsavedActivity(id: activity.id, generalActivity: generalActivity, createdAt: activity.createdAt, studentId: activity.studentId)
                    onSave(updatedActivity)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct UnsavedActivityCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var generalActivity: String = ""
    let student: Student
    let onSave: (UnsavedActivity) -> Void
    
    let selectedDate: Date

    var body: some View {
        NavigationView {
            Form {
                TextField("Activity", text: $generalActivity)
            }
            .navigationTitle("New Activity")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let newActivity = UnsavedActivity(generalActivity: generalActivity, createdAt: selectedDate, studentId: student.id)
                    onSave(newActivity)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            print("ActivityCreateView appeared for student: \(student.fullname)")
        }
    }
}

