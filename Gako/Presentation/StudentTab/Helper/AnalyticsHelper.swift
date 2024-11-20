//
//  AnalyticsHelper.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A helper for tracking general analytics events with student context
//  Usage: Use these methods to track student-related activity events and status changes
//

import SwiftUI
import Mixpanel

enum AnalyticsHelper {
    static func trackStatusChange(
        analytics: InputAnalyticsTracking,
        student: Student,
        activity: Activity,
        oldStatus: Status,
        newStatus: Status
    ) {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_id": activity.id.uuidString,
            "old_status": oldStatus.rawValue,
            "new_status": newStatus.rawValue,
            "screen": "preview",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Status Changed", properties: properties)
    }
    
    static func trackActivityAction(
        analytics: InputAnalyticsTracking,
        action: String,
        student: Student,
        activity: Activity,
        status: Status
    ) {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_id": activity.id.uuidString,
            "status": status.rawValue,
            "screen": "preview",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent(action, properties: properties)
    }
}
