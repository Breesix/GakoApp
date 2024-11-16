//
//  ActivitySection.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct ActivitySection: View {
    let activities: [Activity]
    
    let onDeleteActivity: (Activity) -> Void
    let onStatusChanged: (Activity, Status) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AKTIVITAS")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondaryBlack)
            } else {
                ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                    ActivityRow(
                        activity: activity,
                        onDelete: { _ in onDeleteActivity(activity) },
                        onStatusChanged: onStatusChanged
                        )
                }
            }
            
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
