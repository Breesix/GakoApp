//  ActivityRowPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//

import SwiftUI
import Mixpanel

struct ActivityRowPreview: View {
    @Binding var activity: UnsavedActivity
    let student: Student
    let onAddActivity: () -> Void
    let onDelete: () -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void
    private let analytics = InputAnalyticsTracker.shared
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(activity.activity)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .padding(.bottom, 12)
            
            HStack(spacing: 8) {
                StatusPicker(
                    status: $activity.status,
                    onStatusChange: { newStatus in
                       
                        let properties: [String: MixpanelType] = [
                            "student_id": student.id.uuidString,
                            "activity_id": activity.id.uuidString,
                            "old_status": activity.status.rawValue,
                            "new_status": newStatus.rawValue,
                            "screen": "preview",
                            "timestamp": Date().timeIntervalSince1970
                        ]
                        analytics.trackEvent("Activity Status Changed", properties: properties)
                        
                        activity.status = newStatus
                    }
                )
                
                Button(action: {
                    // Track delete attempt
                    let properties: [String: MixpanelType] = [
                        "student_id": student.id.uuidString,
                        "activity_id": activity.id.uuidString,
                        "status": activity.status.rawValue,
                        "screen": "preview",
                        "timestamp": Date().timeIntervalSince1970
                    ]
                    analytics.trackEvent("Activity Delete Attempted", properties: properties)
                    
                    showDeleteAlert = true
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 34)
                            .foregroundStyle(.buttonDestructiveOnCard)
                        Image(systemName: "trash.fill")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundStyle(.destructiveOnCardLabel)
                    }
                }
                .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                    Button("Hapus", role: .destructive) {
                        // Track deletion
                        let properties: [String: MixpanelType] = [
                            "student_id": student.id.uuidString,
                            "activity_id": activity.id.uuidString,
                            "status": activity.status.rawValue,
                            "screen": "preview",
                            "timestamp": Date().timeIntervalSince1970
                        ]
                        analytics.trackEvent("Activity Deleted", properties: properties)
                        
                        onDeleteActivity(activity)
                        onDelete()
                    }
                    Button("Batal", role: .cancel) { }
                } message: {
                    Text("Apakah kamu yakin ingin menghapus catatan ini?")
                }
            }
        }
    }
}

#Preview {
    ActivityRowPreview(
        activity: .constant(.init(
            activity: "Menjahit",
            createdAt: .now,
            studentId: Student.ID()
        )),
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        onAddActivity: { print("added activity") },
        onDelete: { print("deleted") },
        onDeleteActivity: { _ in print("deleted activity") }
    )
}
