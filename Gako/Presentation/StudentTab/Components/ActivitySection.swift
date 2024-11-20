//
//  ActivitySection.swift
//  Gako
//
//  Created by Rangga Biner on 01/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A section component that displays a list of activities with status picker
//  Usage: Use this component to show activities list section with modifiable status
//

import SwiftUI

struct ActivitySection: View {
    // MARK: - Constants
    private let titleColor: Color = UIConstants.ActivitySection.titleColor
    private let emptyTextColor: Color = UIConstants.ActivitySection.emptyTextColor
    private let emptyState: String = UIConstants.ActivitySection.emptyState
    private let title: String = UIConstants.ActivitySection.title
    private let spacing: CGFloat = UIConstants.ActivitySection.sectionSpacing
    
    // MARK: - Properties
    let activities: [Activity]
    let onStatusChanged: (Activity, Status) -> Void
    
    // MARK: - Body
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
    
    // MARK: - Subview
    private var sectionTitle: some View {
        Text(title)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(titleColor)
    }
    
    // MARK: - Subview
    private var emptyStateText: some View {
        Text(emptyState)
            .foregroundColor(emptyTextColor)
    }
    
    // MARK: - Subview
    private var activitiesList: some View {
        ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
            ActivityRow(
                activity: activity,
                onStatusChanged: onStatusChanged
            )
        }
    }
}

// MARK: - Preview
#Preview {
    ActivitySection(
        activities: [
            .init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(activity: "Motorik Halus", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
        ],
        onStatusChanged: { _, _ in print("changed") }
    )
    .padding(.bottom, 300)
    
    //empty state:
    ActivitySection(
        activities: [
        ],
        onStatusChanged: { _, _ in print("changed") }
    )
}
