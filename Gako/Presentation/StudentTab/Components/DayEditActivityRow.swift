//
//  DayEditActivityRow.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom row component for editing daily activities
//  Usage: Implement this component in lists or forms where activity editing is needed
//

import SwiftUI

struct DayEditActivityRow: View {
    // MARK: - Constants
    private let spacing: CGFloat = UIConstants.DayEdit.spacing
    private let activitySectionTitle: String = UIConstants.DayEdit.activitySectionTitle
    private let titleColor: Color = UIConstants.DayEdit.titleColor
    
    // MARK: - Properties
    let activity: Activity
    let index: Int
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    let date: Date
    let onDelete: (Activity) -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            activitySection
            EditTextField(
                text: EditBindingHelper.makeActivityBinding(
                    activity: activity,
                    editedActivities: $editedActivities,
                    date: date
                )
            )
            StatusPicker(
                status: EditBindingHelper.makeStatusBinding(
                    activity: activity,
                    editedActivities: $editedActivities,
                    date: date
                )
            ) { newStatus in
                let currentText = editedActivities[activity.id]?.0 ?? activity.activity
                editedActivities[activity.id] = (currentText, newStatus, date)
            }
        }
    }
    
    // MARK: - Subview
    private var activitySection: some View {
        HStack {
            Text("\(activitySectionTitle) \(index)")
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(titleColor)
            Spacer()
            DeleteButton(action: { onDelete(activity) })
        }
    }
}

// MARK: - Preview
#Preview {
    DayEditActivityRow(
        activity: Activity(
            id: UUID(),
            activity: "Sample Activity",
            status: .dibimbing, student: .init(fullname: "Rangga", nickname: "rangga")
        ),
        index: 1,
        editedActivities: .constant([:]),
        date: Date(),
        onDelete: { _ in }
    )
}
