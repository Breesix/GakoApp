//
//  DayEditNewActivityRow.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct DayEditNewActivityRow: View {
    let newActivity: (id: UUID, activity: String, status: Status)
    let index: Int
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    let date: Date
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.DayEdit.spacing) {
            HStack {
                Text("\(UIConstants.DayEdit.activitySectionTitle) \(index)")
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(UIConstants.DayEdit.titleColor)
                
                Spacer()
                
                DeleteButton(action: onDelete)
            }
            
            EditTextField(
                text: Binding(
                    get: { editedActivities[newActivity.id]?.0 ?? newActivity.activity },
                    set: { newValue in
                        let status = editedActivities[newActivity.id]?.1 ?? newActivity.status
                        editedActivities[newActivity.id] = (newValue, status, date)
                    }
                )
            )
            
            StatusPicker(
                status: Binding(
                    get: { editedActivities[newActivity.id]?.1 ?? newActivity.status },
                    set: { newValue in
                        let currentText = editedActivities[newActivity.id]?.0 ?? newActivity.activity
                        editedActivities[newActivity.id] = (currentText, newValue, date)
                    }
                )
            ) { newStatus in
                let currentText = editedActivities[newActivity.id]?.0 ?? newActivity.activity
                editedActivities[newActivity.id] = (currentText, newStatus, date)
            }
        }
    }
}
