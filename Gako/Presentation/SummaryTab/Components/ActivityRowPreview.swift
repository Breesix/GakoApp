//  ActivityRowPreview.swift
//  Gako
//
//  Created by Kevin Fairuz on 26/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component for each editable activity
//  Usage: Use this component to display an activity
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
    
    private let spacing = UIConstants.ActivityRow.spacing
    private let deleteButtonSize = UIConstants.ActivityRow.deleteButtonSize
    private let cornerRadius = UIConstants.ActivityRow.cornerRadius
    private let strokeWidth = UIConstants.ActivityRow.strokeWidth
    private let contentPadding = UIConstants.ActivityRow.contentPadding
    private let statusPickerSpacing = UIConstants.ActivityRow.statusPickerSpacing
    private let primaryTextColor = UIConstants.ActivityRow.primaryText
    private let destructiveButtonColor = UIConstants.ActivityRow.destructiveButton
    private let destructiveLabelColor = UIConstants.ActivityRow.destructiveLabel
    private let backgroundColor = UIConstants.ActivityRow.background
    private let strokeColor = UIConstants.ActivityRow.stroke
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack {
                Text("Aktivitas \(activityIndex + 1)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(primaryTextColor)
                
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
                            .frame(width: deleteButtonSize)
                            .foregroundStyle(destructiveButtonColor)
                        Image(systemName: "trash.fill")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundStyle(destructiveLabelColor)
                    }
                }
            }
            
            Text(activity.activity)
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundStyle(primaryTextColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(contentPadding)
                .background(backgroundColor)
                .cornerRadius(cornerRadius)
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(strokeColor, lineWidth: strokeWidth)
                }
                .onTapGesture {
                    onEdit(activity)
                }
            
            HStack(spacing: statusPickerSpacing) {
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

