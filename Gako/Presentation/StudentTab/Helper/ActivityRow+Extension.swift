//
//  ActivityRow+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension for ActivityRow that provides analytics tracking functionality
//  Usage: Use these methods to track activity-related events such as status changes and deletion actions
//

import Mixpanel

extension ActivityRow {
    // MARK: - Track Status Change
    func trackStatusChange(_ newStatus: Status) {
        ActivityAnalyticsHelper.trackStatusChange(
            analytics: analytics,
            activity: activity,
            oldStatus: status,
            newStatus: newStatus
        )
    }
}
