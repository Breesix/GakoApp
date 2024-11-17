//
//  EditActivitySection.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI
import Mixpanel

struct EditActivitySection: View {
    let student: Student
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    let activities: [Activity]
    let onActivityUpdate: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let allActivities: [Activity]
    let allStudents: [Student]
    let onStatusChanged: (Activity, Status) -> Void
    let onAddActivity: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("AKTIVITAS")
                .foregroundStyle(.labelPrimaryBlack)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.bottom, 16)
            
            if !activities.isEmpty {
                ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                    EditActivityRow(
                        activity: binding(for: activity),
                        activityIndex: index,
                        student: student,
                        onAddActivity: {
                            isAddingNewActivity = true
                        },
                        onEdit: { activity in
                            onActivityUpdate(activity)
                        },
                        onDelete: {
                            onDeleteActivity(activity)
                        },
                        onDeleteActivity: onDeleteActivity, onStatusChanged: onStatusChanged
                    )
                    .padding(.bottom, 16)
                }
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondaryBlack)
                    .padding(.bottom, 12)
            }
            
            AddItemButton(
                onTapAction: {
                    onAddActivity()
                },
                bgColor: .buttonOncard, text: "Tambah"
            )
        }
    }
    
    private func binding(for activity: Activity) -> Binding<Activity> {
        Binding(
            get: { activity },
            set: { newValue in
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
