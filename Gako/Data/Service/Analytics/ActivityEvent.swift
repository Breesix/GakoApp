//
//  ActivityEvent.swift
//  Breesix
//
//  Created by Kevin Fairuz on 06/11/24.
//
import SwiftUI
import Mixpanel

struct ActivityEvent: AnalyticsEvent {
    let name: AnalyticsEventType
    let properties: [String: MixpanelType]
    
    init(
        type: AnalyticsEventType,
        studentId: String,
        activityText: String,
        status: Status,
        createdAt: Date,
        screen: String
    ) {
        self.name = type
        self.properties = [
            "student_id": studentId,
            "activity_text_length": activityText.count,
            "status": status.rawValue,
            "created_at": createdAt.timeIntervalSince1970,
            "screen": screen,
            "timestamp": Date().timeIntervalSince1970
        ]
    }
}
