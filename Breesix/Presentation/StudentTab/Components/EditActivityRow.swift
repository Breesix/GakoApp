//
//  EditActivityRow.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI
import Mixpanel

struct EditActivityRow: View {
    @Binding var activity: Activity
    let activityIndex: Int
    let student: Student
    let onAddActivity: () -> Void
    let onEdit: (Activity) -> Void
    let onDelete: () -> Void
    let onDeleteActivity: (Activity) -> Void
    let onStatusChanged: (Activity, Status) -> Void
    private let analytics = InputAnalyticsTracker.shared
    
    @State private var showDeleteAlert = false
    @State private var status: Status
    
    init(activity: Binding<Activity>,
         activityIndex: Int,
         student: Student,
         onAddActivity: @escaping () -> Void,
         onEdit: @escaping (Activity) -> Void,
         onDelete: @escaping () -> Void,
         onDeleteActivity: @escaping (Activity) -> Void,
         onStatusChanged: @escaping (Activity, Status) -> Void) {
        self._activity = activity
        self.activityIndex = activityIndex
        self.student = student
        self.onAddActivity = onAddActivity
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onDeleteActivity = onDeleteActivity
        self.onStatusChanged = onStatusChanged
        _status = State(initialValue: activity.wrappedValue.status)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Aktivitas \(activityIndex + 1)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
                
                Spacer()
                
                Button(action: {
                    trackDeleteAttempt()
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
                StatusPicker(status: $status) { newStatus in
                    trackStatusChange(newStatus)
                    activity.status = newStatus
                    onStatusChanged(activity, newStatus)
                }
            }
        }
        .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
            Button("Hapus", role: .destructive) {
                trackDeletion()
                onDeleteActivity(activity)
                onDelete()
            }
            Button("Batal", role: .cancel) { }
        } message: {
            Text("Apakah kamu yakin ingin menghapus catatan ini?")
        }
        .onAppear {
            status = activity.status
        }
    }
    
    // MARK: - Tracking Methods
    private func trackStatusChange(_ newStatus: Status) {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_id": activity.id.uuidString,
            "old_status": status.rawValue,
            "new_status": newStatus.rawValue,
            "screen": "preview",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Status Changed", properties: properties)
    }
    
    private func trackDeleteAttempt() {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_id": activity.id.uuidString,
            "status": status.rawValue,
            "screen": "preview",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Delete Attempted", properties: properties)
    }
    
    private func trackDeletion() {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_id": activity.id.uuidString,
            "status": status.rawValue,
            "screen": "preview",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Deleted", properties: properties)
    }
}
    
#Preview {
    EditActivityRow(activity: .constant(.init(
        activity: "Menjahit",
        createdAt: .now, student: .init(fullname: "Rangga Biner", nickname: "rangga")
    )), activityIndex: 0, student: .init(fullname: "Rangga bienr", nickname: "rangga"), onAddActivity: { print("added activity") }, onEdit:  { _ in print("edit activity") }, onDelete: { print("deleted") }, onDeleteActivity: { _ in print("deleted activity") }, onStatusChanged: { _,_  in print("status changed")})
}

