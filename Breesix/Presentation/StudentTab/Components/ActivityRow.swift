//
//  ActivityRow.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI
import Mixpanel

struct ActivityRow: View {
    let activity: Activity
    let onDelete: (Activity) -> Void
    let onStatusChanged: (Activity, Status) -> Void
    @State private var showDeleteAlert = false
    @State private var status: Status
    private let analytics = InputAnalyticsTracker.shared
    
    init(activity: Activity,
         onDelete: @escaping (Activity) -> Void,
         onStatusChanged: @escaping (Activity, Status) -> Void) {
        self.activity = activity
        self.onDelete = onDelete
        self.onStatusChanged = onStatusChanged
        _status = State(initialValue: activity.status)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(activity.activity)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .padding(.bottom, 12)
            
            HStack(spacing: 8) {
                StatusPicker(status: $status) { newStatus in
                
                    trackStatusChange(newStatus)
                    onStatusChanged(activity, newStatus)
                }
                
//                Button(action: {
//                    showDeleteAlert = true
//                    trackDeleteAttempt()
//                   
//                }) {
//                    Image("custom.trash.circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 34)
//                }
//                .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
//                    Button("Hapus", role: .destructive) {
//                        onDelete(activity)
//                        trackDeletion()
//                       
//                    }
//                    Button("Batal", role: .cancel) { }
//                } message: {
//                    Text("Apakah kamu yakin ingin menghapus aktivitas ini?")
//                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            status = activity.status
        }
    }
    
    // MARK: - Tracking Methods
    private func trackStatusChange(_ newStatus: Status) {
        let properties: [String: MixpanelType] = [
            "activity_text": activity.activity,
            "old_status": status.rawValue,
            "new_status": newStatus.rawValue,
            "screen": "activity_list",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Status Changed", properties: properties)
    }
    
    private func trackDeleteAttempt() {
        let properties: [String: MixpanelType] = [
            "activity_text": activity.activity,
            "status": status.rawValue,
            "screen": "activity_list",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Delete Attempted", properties: properties)
    }
    
    private func trackDeletion() {
        let properties: [String: MixpanelType] = [
            "activity_text": activity.activity,
            "status": status.rawValue,
            "screen": "activity_list",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Deleted", properties: properties)
    }
}

#Preview {
    ActivityRow(activity: .init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onDelete: {_ in print("deleted")}, onStatusChanged: { _, _ in print("changed")})
}
