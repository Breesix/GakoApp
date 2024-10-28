
//
//  ActivitySectionView.swift
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
    
    var body: some View {
        let studentActivities = viewModel.unsavedActivities.filter { $0.studentId == student.id }
        
        if !studentActivities.isEmpty {
                ForEach(studentActivities) { activity in
                    ActivityDetailRow(
                        activity: binding(for: activity, in: viewModel),
                        student: student,
                        onAddActivity: {
                            isAddingNewActivity = true
                        },
                        onDelete: {
                            viewModel.deleteUnsavedActivity(activity)
                        }
                    )
                    .padding(.bottom, 12)
                }
                
                AddButton{
                    selectedStudent = student
                    isAddingNewActivity = true
                }
        } else {
            Text("No activities for this student.")
                .italic()
                .foregroundColor(.gray)
        }
    }
    
    private func binding(for activity: UnsavedActivity, in viewModel: StudentTabViewModel) -> Binding<UnsavedActivity> {
        let index = viewModel.unsavedActivities.firstIndex { $0.id == activity.id }!
        return .init(
            get: { viewModel.unsavedActivities[index] },
            set: { viewModel.unsavedActivities[index] = $0 }
        )
    }
}
