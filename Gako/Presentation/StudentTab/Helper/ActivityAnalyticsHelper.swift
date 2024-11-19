//
//  ActivityAnalyticsHelper.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI
import Mixpanel

enum ActivityAnalyticsHelper {
    static func trackStatusChange(
        analytics: InputAnalyticsTracking,
        activity: Activity,
        oldStatus: Status,
        newStatus: Status
    ) {
        let properties: [String: MixpanelType] = [
            "activity_text": activity.activity,
            "old_status": oldStatus.rawValue,
            "new_status": newStatus.rawValue,
            "screen": UIConstants.Activity.Analytics.screenActivityList,
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent(
            UIConstants.Activity.Analytics.eventStatusChanged,
            properties: properties
        )
    }
    
    static func trackActivityAction(
        analytics: InputAnalyticsTracking,
        action: String,
        activity: Activity,
        status: Status
    ) {
        let properties: [String: MixpanelType] = [
            "activity_text": activity.activity,
            "status": status.rawValue,
            "screen": UIConstants.Activity.Analytics.screenActivityList,
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent(action, properties: properties)
    }
}
