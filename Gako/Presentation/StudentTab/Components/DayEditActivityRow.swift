//
//  DayEditActivityRow.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct DayEditActivityRow: View {
    let activity: Activity
    let index: Int
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    let date: Date
    let onDelete: (Activity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.DayEdit.spacing) {
            HStack {
                Text("\(UIConstants.DayEdit.activitySectionTitle) \(index)")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(UIConstants.DayEdit.titleColor)
                
                Spacer()
                
                DeleteButton(action: { onDelete(activity) })
            }
            
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
}
