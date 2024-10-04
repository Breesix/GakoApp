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

    var body: some View {
        NavigationView {
            List {
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
                    isShowingPreview = false
                },
                trailing: Button("Simpan") {
                    saveActivities()
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
            ActivityEditView(activity: activity, onSave: { updatedActivity in
                updateActivity(updatedActivity)
            })
        }
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                ActivityCreateView(student: student, onSave: { newActivity in
                    addNewActivity(newActivity)
                })
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

struct ActivityEditView: View {
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


struct ActivityCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var generalActivity: String = ""
    let student: Student
    let onSave: (UnsavedActivity) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Activity", text: $generalActivity)
            }
            .navigationTitle("New Activity")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let newActivity = UnsavedActivity(generalActivity: generalActivity, createdAt: Date(), studentId: student.id)
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

