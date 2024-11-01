
//
//  ActivitySectionPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct ActivitySectionPreview: View {
    let student: Student
    let viewModel: StudentTabViewModel
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    let onDeleteActivity: (UnsavedActivity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
            
            if !studentActivities.isEmpty {
                ForEach(studentActivities) { activity in
                    ActivityRowPreview(
                        viewModel: viewModel,
                        activity: binding(for: activity, in: viewModel),
                        student: student,
                        onAddActivity: {
                            isAddingNewActivity = true
                        },
                        onDelete: {
                            onDeleteActivity(activity)
                        }
                    )
                    .padding(.bottom, 12)
                }
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
            }
            
            AddButton(
                action: {
                    selectedStudent = student
                    isAddingNewActivity = true
                },
                backgroundColor: .buttonOncard
            )
        }
    }
    
    private func binding(for activity: UnsavedActivity, in viewModel: StudentTabViewModel) -> Binding<UnsavedActivity> {
        Binding<UnsavedActivity>(
            get: {
                if let index = viewModel.unsavedActivities.firstIndex(where: { $0.id == activity.id }) {
                    return viewModel.unsavedActivities[index]
                }
                return activity
            },
            set: { newValue in
                if let index = viewModel.unsavedActivities.firstIndex(where: { $0.id == activity.id }) {
                    viewModel.unsavedActivities[index] = newValue
                }
            }
        )
    }
}
