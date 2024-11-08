//  ActivityRowPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//

import SwiftUI
import Mixpanel

struct ActivityRowPreview: View {
    @Binding var activity: UnsavedActivity
    let activityIndex: Int
    let student: Student
    let onAddActivity: () -> Void
    let onEdit: (UnsavedActivity) -> Void
    let onDelete: () -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void
    private let analytics = InputAnalyticsTracker.shared
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Aktivitas \(activityIndex + 1)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
                
                Spacer()
                
                Button(action: {
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
            }
            
            Text(activity.activity)
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundStyle(.labelPrimaryBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.monochrome100)
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.noteStroke, lineWidth: 0.5)
                }
                .onTapGesture {
                    onEdit(activity)
                }

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
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(.monochrome100)
                        .cornerRadius(8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.noteStroke, lineWidth: 0.5)
                        }
                        .onTapGesture {
                            onEdit(activity)
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
            activityIndex: 0,
            student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
            onAddActivity: { print("added activity") },
            onEdit: { _ in print("edit activity") },
            onDelete: { print("deleted") },
            onDeleteActivity: { _ in print("deleted activity") }
        )
    }

