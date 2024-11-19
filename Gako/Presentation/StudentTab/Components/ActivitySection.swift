//
//  ActivitySection.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct ActivitySection: View {
    // MARK: - Constants
    private let titleColor = UIConstants.Activity.titleColor
    private let emptyTextColor = UIConstants.Activity.emptyTextColor
    private let spacing = UIConstants.Activity.sectionSpacing
    
    // MARK: - Properties
    let activities: [Activity]
    let onDeleteActivity: (Activity) -> Void
    let onStatusChanged: (Activity, Status) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            sectionTitle
            
            if activities.isEmpty {
                emptyStateText
            } else {
                activitiesList
            }
        }
    }
    
    // MARK: - Subviews
    private var sectionTitle: some View {
        Text(UIConstants.Activity.sectionTitle)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(titleColor)
    }
    
    private var emptyStateText: some View {
        Text(UIConstants.Activity.emptyStateText)
            .foregroundColor(emptyTextColor)
    }
    
    private var activitiesList: some View {
        ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
            ActivityRow(
                activity: activity,
                onDelete: { _ in onDeleteActivity(activity) },
                onStatusChanged: onStatusChanged
            )
        }
    }
}

#Preview {
    ActivitySection(
        activities: [
            .init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(activity: "Motorik Halus", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
        ],
        onDeleteActivity: { _ in print("deleted") },
        onStatusChanged: { _, _ in print("changed") }
    )
    .padding(.bottom, 300)
    
    //empty state:
    ActivitySection(
        activities: [
        ],
        onDeleteActivity: { _ in print("deleted") },
        onStatusChanged: { _, _ in print("changed") }
    )
}
