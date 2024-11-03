//
//  ActivitySectionPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct ActivitySectionPreview: View {
    let student: Student
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    
    let activities: [UnsavedActivity]
    let onActivityUpdate: (UnsavedActivity) -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let studentActivities = activities.filter { $0.studentId == student.id }
            
            if !studentActivities.isEmpty {
                ForEach(studentActivities) { activity in
                    ActivityRowPreview(
                        activity: binding(for: activity),
                        student: student,
                        onAddActivity: {
                            isAddingNewActivity = true
                        },
                        onDelete: {
                            onDeleteActivity(activity)
                        },
                        onDeleteActivity: { activity in
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
    
    private func binding(for activity: UnsavedActivity) -> Binding<UnsavedActivity> {
        Binding<UnsavedActivity>(
            get: { activity },
            set: { newValue in
                onActivityUpdate(newValue)
            }
        )
    }
}

#Preview {
    ActivitySectionPreview(
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        selectedStudent: .constant(nil),
        isAddingNewActivity: .constant(false),
        activities: [
            UnsavedActivity(
                activity: "Reading a book",
                createdAt: Date(),
                status: .mandiri,
                studentId: Student.ID()
            ),
            UnsavedActivity(
                activity: "Playing with blocks",
                createdAt: Date(),
                status: .mandiri,
                studentId: Student.ID()
            )
        ],
        onActivityUpdate: { _ in },
        onDeleteActivity: { _ in }
    )
}
