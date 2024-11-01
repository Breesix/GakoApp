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
    let onStatusChanged: (Activity, Bool?) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
            } else {
                ForEach(activities, id: \.id) { activity in
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
