//
//  ActivitySectionPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI
import Mixpanel

struct ActivitySectionPreview: View {
    let student: Student
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    
    let activities: [UnsavedActivity]
    @State private var editingActivity: UnsavedActivity?
    
    let onActivityUpdate: (UnsavedActivity) -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void
    
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    let allActivities: [UnsavedActivity]
    let allStudents: [Student]

    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("AKTIVITAS")
                .foregroundStyle(.labelPrimaryBlack)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.bottom, 16)

            let studentActivities = activities.filter { $0.studentId == student.id }
            
            if !studentActivities.isEmpty {
                ForEach(Array(studentActivities.enumerated()), id: \.element.id) { index, activity in
                    ActivityRowPreview(
                        activity: binding(for: activity),
                        activityIndex: index,
                        student: student,
                        onAddActivity: {
                            isAddingNewActivity = true
                        },
                        onEdit: { activity in
                            editingActivity = activity
                        },
                        onDelete: {
                            onDeleteActivity(activity)
                        },
                        onDeleteActivity: { activity in
                            onDeleteActivity(activity)
                        }
                    )
                    .padding(.bottom, 16)
                }
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
                    .padding(.bottom, 12)
            }
            
            AddButton(
                action: {
                    selectedStudent = student
                    isAddingNewActivity = true
                },
                backgroundColor: .buttonOncard
            )
        }
        .sheet(item: $editingActivity) { activity in
            ManageUnsavedActivityView(
                mode: .edit(activity),
                allActivities: allActivities,
                allStudents: allStudents,
                onSave: { updatedActivity in
                    onActivityUpdate(updatedActivity)
                    editingActivity = nil
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }

    }
    
    private func binding(for activity: UnsavedActivity) -> Binding<UnsavedActivity> {
            Binding<UnsavedActivity>(
                get: { activity },
                set: { newValue in
                    if newValue.status != activity.status {
                        // Track status change
                        let properties: [String: MixpanelType] = [
                            "student_id": student.id.uuidString,
                            "activity_id": activity.id.uuidString,
                            "old_status": activity.status.rawValue,
                            "new_status": newValue.status.rawValue,
                            "screen": "preview",
                            "timestamp": Date().timeIntervalSince1970
                        ]
                        analytics.trackEvent("Activity Status Changed", properties: properties)
                    }
                    onActivityUpdate(newValue)
                }
            )
        }
    
}


//#Preview {
//    ActivitySectionPreview(
//        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
//        selectedStudent: .constant(nil),
//        isAddingNewActivity: .constant(false),
//        activities: [
//            UnsavedActivity(
//                activity: "Reading a book",
//                createdAt: Date(),
//                status: .mandiri,
//                studentId: Student.ID()
//            ),
//            UnsavedActivity(
//                activity: "Playing with blocks",
//                createdAt: Date(),
//                status: .mandiri,
//                studentId: Student.ID()
//            )
//        ],
//        onActivityUpdate: { _ in },
//        onDeleteActivity: { _ in }
//    )
//}
