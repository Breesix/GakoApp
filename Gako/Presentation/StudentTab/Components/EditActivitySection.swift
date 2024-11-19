//
//  EditActivitySection.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI
import Mixpanel

struct EditActivitySection: View {
    // MARK: - Constants
    private let sectionTitle = UIConstants.EditActivity.sectionTitle
    private let emptyStateText = UIConstants.EditActivity.emptyStateText
    private let addButtonText = UIConstants.EditActivity.addButtonText
    private let bottomPadding = UIConstants.EditActivity.bottomPadding
    private let rowBottomPadding = UIConstants.EditActivity.rowBottomPadding
    
    // MARK: - Properties
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
            Text(sectionTitle)
                .foregroundStyle(.labelPrimaryBlack)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.bottom, bottomPadding)
            
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
                        onDeleteActivity: onDeleteActivity,
                        onStatusChanged: onStatusChanged
                    )
                    .padding(.bottom, bottomPadding)
                }
            } else {
                Text(emptyStateText)
                    .foregroundColor(.labelSecondaryBlack)
                    .padding(.bottom, rowBottomPadding)
            }
            
            AddItemButton(
                onTapAction: onAddActivity,
                bgColor: .buttonOncard,
                text: addButtonText
            )
        }
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
