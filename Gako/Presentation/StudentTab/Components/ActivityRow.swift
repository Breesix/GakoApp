//
//  ActivityRow.swift
//  Gako
//
//  Created by Rangga Biner on 01/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component that row of activity
//  Usage: Use this component to display activity row including name of activity and status picker
//

import SwiftUI
import Mixpanel

struct ActivityRow: View {
    // MARK: - Dependencies
    let analytics = InputAnalyticsTracker.shared

    // MARK: - Constants
    private let titleColor: Color = UIConstants.ActivityRow.titleColor
    private let defaultSpacing: CGFloat = UIConstants.ActivityRow.defaultSpacing
    private let statusPickerSpacing: CGFloat = UIConstants.ActivityRow.statusPickerSpacing

    // MARK: - Properties
    let activity: Activity
    let onStatusChanged: (Activity, Status) -> Void

    // MARK: - State Variables
    @State var showDeleteAlert = false
    @State var status: Status

    // MARK: - Initialization
    init(activity: Activity,
         onStatusChanged: @escaping (Activity, Status) -> Void) {
        self.activity = activity
        self.onStatusChanged = onStatusChanged
        _status = State(initialValue: activity.status)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: defaultSpacing) {
            activityTitle
            statusPickerView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            status = activity.status
        }
    }
    
    // MARK: - Subview
    private var activityTitle: some View {
        Text(activity.activity)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(titleColor)
    }
    
    // MARK: - Subview
    private var statusPickerView: some View {
        HStack(spacing: statusPickerSpacing) {
            StatusPicker(status: $status) { newStatus in
                trackStatusChange(newStatus)
                onStatusChanged(activity, newStatus)
            }
        }
    }    
}

// MARK: - Preview
#Preview {
    ActivityRow(activity: .init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onStatusChanged: { _, _ in print("changed")})
}
