//
//  ActivityPreviewView.swift
//  Breesix
//
//  Created by Akmal Hakim on 03/10/24.
//

import SwiftUI

struct ActivityPreviewView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowingActivity: Bool
    @State private var isSaving = false
    @State private var unsavedActivity: UnsavedActivity?
    @State private var isAddingNewActivity = false
    @State private var selectedStudent: Student?
    var onDismiss: () -> Void
    
        
    
    var body: some View {
        NavigationView {
            //            List {
            //                ForEach(viewModel.students) { student in
            //                    let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
            //                    if !studentActivities.isEmpty {
            //                        Section(header: Text(student.fullname)) {
            //                            ForEach(studentActivities) { activity in
            //                                ActivityDetailRow(activity: activity, student: student, onEdit: {
            //                                    unsavedActivity = activity
            //                                }, onDelete: {
            //                                    deleteUnsavedActivity(activity)
            //                                })
            //                            }
            //                        }
            //                    }
            //                }
            //            }
            //            .navigationTitle("Preview Aktivitas")
            //            .navigationBarItems(
            //                leading: Button("Cancel") {
            //                    viewModel.clearUnsavedActivities()
            //                    isShowingActivity = false
            //                },
            //                trailing: Button("Save") {
            //                    saveActivities()
            //                }
            //                .disabled(isSaving)
            //            )
            //            .overlay(
            //                Group {
            //                    if isSaving {
            //                        ProgressView("Saving...")
            //                            .padding()
            //                            .background(Color.secondary.colorInvert())
            //                            .cornerRadius(10)
            //                            .shadow(radius: 10)
            //                    }
            //                }
            //            )
        }
        .sheet(item: $unsavedActivity) { activity in
            UnsavedActivityEditView(unsavedActivity: activity, onSave: { updatedActivity in
                updateUnsavedActivity(updatedActivity)
            })
        }
    }
    
    private func saveActivities() {
        isSaving = true
        Task {
            try await viewModel.saveUnsavedActivities()
            await MainActor.run {
                isSaving = false
                isShowingActivity = false
            }
        }
    }
    
    private func deleteUnsavedActivity(_ activity: UnsavedActivity) {
        viewModel.deleteUnsavedActivity(activity)
    }
    
    private func updateUnsavedActivity(_ updatedActivity: UnsavedActivity) {
        viewModel.updateUnsavedActivity(updatedActivity)
    }
}

struct ActivityDetailRow: View {
    @Binding var activity: UnsavedActivity
    let student: Student
    let onAddActivity: () -> Void
    let onDelete: () -> Void
    @State private var showPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(activity.activity)
                .font(.headline)
            
            // Dropdown menu
            Menu {
                Button(action: {
                    activity.isIndependent = true
                }) {
                    HStack {
                        Text("Mandiri")
                        if activity.isIndependent == true {
                            Image(systemName: "checkmark")
                        }
                    }
                }
                
                Button(action: {
                    activity.isIndependent = false
                }) {
                    HStack {
                        Text("Dibimbing")
                        if activity.isIndependent == false {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                HStack {
                    Text(activity.isIndependent == true ? "Mandiri" : "Dibimbing")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            HStack {
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            .padding(.top, 4)
        }
        .padding()
    }
}




struct UnsavedActivityEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var activityText: String
    @State private var isIndependent: Bool
    let unsavedActivity: UnsavedActivity
    let onSave: (UnsavedActivity) -> Void
    
    init(unsavedActivity: UnsavedActivity, onSave: @escaping (UnsavedActivity) -> Void) {
        self.unsavedActivity = unsavedActivity
        self.onSave = onSave
        _activityText = State(initialValue: unsavedActivity.activity)
        _isIndependent = State(initialValue: unsavedActivity.isIndependent!)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Activity Detail", text: $activityText)
                Toggle("Independent", isOn: $isIndependent)
            }
            .navigationTitle("Edit Aktivitas")
            .navigationBarItems(
                leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() },
                trailing: Button("Save") {
                    let updatedActivity = UnsavedActivity(id: unsavedActivity.id, activity: activityText, createdAt: unsavedActivity.createdAt, isIndependent: isIndependent, studentId: unsavedActivity.studentId)
                    onSave(updatedActivity)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
