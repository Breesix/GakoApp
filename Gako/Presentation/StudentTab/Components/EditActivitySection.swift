//
//  EditActivitySection.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A section component that manages a collection of student activities
//  Usage: Use this view to display and manage multiple activity entries for a student
//

import SwiftUI
import Mixpanel

struct EditActivitySection: View {
    // MARK: - Constants
    private let sectionTitle = UIConstants.EditActivitySection.sectionTitle
    private let emptyStateText = UIConstants.EditActivitySection.emptyStateText
    private let addButtonText = UIConstants.EditActivitySection.addButtonText
    private let bottomPadding = UIConstants.EditActivitySection.bottomPadding
    private let rowBottomPadding = UIConstants.EditActivitySection.rowBottomPadding
    
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
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection
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
                emptyState
            }
            AddItemButton(
                onTapAction: onAddActivity,
                bgColor: .buttonOncard,
                text: addButtonText
            )
        }
    }
    
    // MARK: - Subview
    private var titleSection: some View {
        Text(sectionTitle)
            .foregroundStyle(.labelPrimaryBlack)
            .font(.callout)
            .fontWeight(.semibold)
            .padding(.bottom, bottomPadding)
    }
    
    // MARK: - Subview
    private var emptyState: some View {
        Text(emptyStateText)
            .foregroundColor(.labelSecondaryBlack)
            .padding(.bottom, rowBottomPadding)
    }
}

// MARK: - Preview
#Preview {
    EditActivitySection(
        student: Student(fullname: "Rangga", nickname: "Biner"),
        selectedStudent: .constant(Student(fullname: "Rangga", nickname: "Biner")),
        isAddingNewActivity: .constant(false),
        activities: [
            Activity(activity: "semua anak makna", student: Student(fullname: "rangga", nickname: "Biner"))
        ],
        onActivityUpdate: { _ in },
        onDeleteActivity: { _ in },
        allActivities: [
            Activity(activity: "sample activity", student: Student(fullname: "Rangga", nickname: "Biner"))
        ],
        allStudents: [
            Student(fullname: "Rangga", nickname: "Biner")
        ],
        onStatusChanged: { _, _ in },
        onAddActivity: { }
    )
}
