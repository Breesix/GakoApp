//
//  ActivityRow.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI
import Mixpanel

struct ActivityRow: View {
    // MARK: - Constants
    private let titleColor = UIConstants.Activity.titleColor
    private let bottomPadding = UIConstants.Activity.rowBottomPadding
    private let statusPickerSpacing = UIConstants.Activity.statusPickerSpacing
    private let analytics = InputAnalyticsTracker.shared
    
    // MARK: - Properties
    let activity: Activity
    let onDelete: (Activity) -> Void
    let onStatusChanged: (Activity, Status) -> Void
    
    @State private var showDeleteAlert = false
    @State private var status: Status
    
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
            activityTitle
            statusPickerView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            status = activity.status
        }
    }
    
    // MARK: - Subviews
    private var activityTitle: some View {
        Text(activity.activity)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(titleColor)
            .padding(.bottom, bottomPadding)
    }
    
    private var statusPickerView: some View {
        HStack(spacing: statusPickerSpacing) {
            StatusPicker(status: $status) { newStatus in
                trackStatusChange(newStatus)
                onStatusChanged(activity, newStatus)
            }
        }
    }
    
    // MARK: - Tracking Methods
    private func trackStatusChange(_ newStatus: Status) {
        ActivityAnalyticsHelper.trackStatusChange(
            analytics: analytics,
            activity: activity,
            oldStatus: status,
            newStatus: newStatus
        )
    }
    
    private func trackDeleteAttempt() {
        ActivityAnalyticsHelper.trackActivityAction(
            analytics: analytics,
            action: UIConstants.Activity.Analytics.eventDeleteAttempted,
            activity: activity,
            status: status
        )
    }
    
    private func trackDeletion() {
        ActivityAnalyticsHelper.trackActivityAction(
            analytics: analytics,
            action: UIConstants.Activity.Analytics.eventDeleted,
            activity: activity,
            status: status
        )
    }
}

#Preview {
    ActivityRow(activity: .init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onDelete: {_ in print("deleted")}, onStatusChanged: { _, _ in print("changed")})
}
