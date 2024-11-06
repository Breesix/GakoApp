//
//  InputAnalyticsTracker.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import Mixpanel
import SwiftUI
import Speech


// MARK: - Analytics Tracker
class InputAnalyticsTracker: InputAnalyticsTracking {
    static let shared = InputAnalyticsTracker()
    private let mixPanelToken: String
    
    private init() {
        self.mixPanelToken = APIConfig.mixPanelToken
        Mixpanel.initialize(token: self.mixPanelToken, trackAutomaticEvents: true)
    }
    
    // MARK: - Protocol Implementation
    func trackInputStarted(type: InputType, date: Date) {
        let properties: [String: MixpanelType] = [
            "input_type": type.rawValue,
            "date": date.timeIntervalSince1970,
            "weekday": Calendar.current.component(.weekday, from: date),
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("\(type.rawValue) Input Started", properties: properties)
    }
    
    func trackInputCompleted(type: InputType, success: Bool, duration: TimeInterval?, textLength: Int) {
        var properties: [String: MixpanelType] = [
            "input_type": type.rawValue,
            "success": success,
            "text_length": textLength,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let duration = duration {
            properties["duration_seconds"] = duration
        }
        
        trackEvent("\(type.rawValue) Input Completed", properties: properties)
    }
    
    func trackInputCancelled(type: InputType) {
        let properties: [String: MixpanelType] = [
            "input_type": type.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("\(type.rawValue) Input Cancelled", properties: properties)
    }
    
    func trackProcessingStarted(type: InputType) {
        let properties: [String: MixpanelType] = [
            "input_type": type.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("\(type.rawValue) Processing Started", properties: properties)
    }
    
    func trackProcessingCompleted(type: InputType, success: Bool, studentsCount: Int) {
        let properties: [String: MixpanelType] = [
            "input_type": type.rawValue,
            "success": success,
            "students_count": studentsCount,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("\(type.rawValue) Processing Completed", properties: properties)
    }
    
    func trackEvent(_ eventName: String, properties: [String: MixpanelType]?) {
        Mixpanel.mainInstance().track(
            event: eventName,
            properties: properties
        )
    }
    
    // MARK: - Additional Activity Tracking Methods
    func trackActivityCreated(studentId: String, activityText: String, status: Status, source: String) {
        let properties: [String: MixpanelType] = [
            "student_id": studentId,
            "activity_length": activityText.count,
            "status": status.rawValue,
            "source": source,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("Activity Created", properties: properties)
    }
    
    func trackActivityUpdated(studentId: String, activityId: String, oldStatus: Status, newStatus: Status) {
        let properties: [String: MixpanelType] = [
            "student_id": studentId,
            "activity_id": activityId,
            "old_status": oldStatus.rawValue,
            "new_status": newStatus.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("Activity Updated", properties: properties)
    }
    
    func trackActivityDeleted(studentId: String, activityId: String, status: Status) {
        let properties: [String: MixpanelType] = [
            "student_id": studentId,
            "activity_id": activityId,
            "status": status.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("Activity Deleted", properties: properties)
    }
    
    // MARK: - Additional Note Tracking Methods
    func trackNoteCreated(studentId: String, noteLength: Int) {
        let properties: [String: MixpanelType] = [
            "student_id": studentId,
            "note_length": noteLength,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("Note Created", properties: properties)
    }
    
    func trackNoteUpdated(studentId: String, noteId: String, oldLength: Int, newLength: Int) {
        let properties: [String: MixpanelType] = [
            "student_id": studentId,
            "note_id": noteId,
            "old_length": oldLength,
            "new_length": newLength,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("Note Updated", properties: properties)
    }
    
    func trackNoteDeleted(studentId: String, noteId: String) {
        let properties: [String: MixpanelType] = [
            "student_id": studentId,
            "note_id": noteId,
            "timestamp": Date().timeIntervalSince1970
        ]
        trackEvent("Note Deleted", properties: properties)
    }
}
