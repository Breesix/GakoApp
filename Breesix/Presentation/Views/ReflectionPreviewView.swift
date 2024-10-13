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
    @State private var editingActivity: UnsavedNote?
    @State private var isAddingNewActivity = false
    @State private var selectedStudent: Student?
    @Binding var isShowingToiletTraining: Bool
    @State private var editingTraining: UnsavedActivity?
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
            UnsavedNoteEditView(activity: activity, onSave: { updatedActivity in
                updateActivity(updatedActivity)
            })
        }
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                UnsavedNoteCreateView(student: student, onSave: { newActivity in
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
    
    private func deleteTraining(_ training: UnsavedActivity) {
        viewModel.deleteUnsavedToiletTraining(training)
    }
    
    private func deleteActivity(_ activity: UnsavedNote) {
        viewModel.deleteUnsavedNote(activity)
    }
    
    private func updateActivity(_ updatedActivity: UnsavedNote) {
        viewModel.updateUnsavedNote(updatedActivity)
    }
    
    private func addNewActivity(_ newActivity: UnsavedNote) {
        viewModel.addUnsavedNote(newActivity)
    }
}

struct ActivityRow: View {
    let activity: UnsavedNote
    let student: Student
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(activity.note)
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

struct UnsavedNoteEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var note: String
    let activity: UnsavedNote
    let onSave: (UnsavedNote) -> Void
    
    init(activity: UnsavedNote, onSave: @escaping (UnsavedNote) -> Void) {
        self.activity = activity
        self.onSave = onSave
        _note = State(initialValue: activity.note)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Activity", text: $note)
            }
            .navigationTitle("Edit Activity")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let updatedActivity = UnsavedNote(id: activity.id, note: note, createdAt: activity.createdAt, studentId: activity.studentId)
                    onSave(updatedActivity)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct UnsavedNoteCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var note: String = ""
    let student: Student
    let onSave: (UnsavedNote) -> Void
    
    let selectedDate: Date

    var body: some View {
        NavigationView {
            Form {
                TextField("Activity", text: $note)
            }
            .navigationTitle("New Activity")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let newActivity = UnsavedNote(note: note, createdAt: selectedDate, studentId: student.id)
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

