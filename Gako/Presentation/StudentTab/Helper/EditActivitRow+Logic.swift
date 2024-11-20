//
//  EditActivitRow+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides analytics tracking and action handling for EditActivityRow
//  Usage: Contains methods for tracking user interactions and handling activity-related actions
//

import Foundation
import Mixpanel

extension EditActivityRow {
    // MARK: - Analytics
    func trackStatusChange(_ newStatus: Status) {
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
    
    func trackDeleteAttempt() {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_id": activity.id.uuidString,
            "status": status.rawValue,
            "screen": "preview",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Delete Attempted", properties: properties)
    }
    
    func trackDeletion() {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_id": activity.id.uuidString,
            "status": status.rawValue,
            "screen": "preview",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Deleted", properties: properties)
    }
    
    // MARK: - Action Handlers
    func handleStatusChange(_ newStatus: Status) {
        trackStatusChange(newStatus)
        activity.status = newStatus
        onStatusChanged(activity, newStatus)
    }
    
    func handleDeleteTap() {
        trackDeleteAttempt()
        showDeleteAlert = true
    }
    
    func handleDeleteConfirmation() {
        trackDeletion()
        onDeleteActivity(activity)
    }
    
    // MARK: - Validation
    func isValidStatus(_ status: Status) -> Bool {
        return status != .tidakMelakukan
    }
    
    func canEdit() -> Bool {
        return !activity.activity.isEmpty
    }
} 
