//
//  InputAnalyticsTracker.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import Mixpanel
import SwiftUI
import Speech


// MARK: - Services/Analytics/InputAnalyticsTracker.swift
class InputAnalyticsTracker: InputAnalyticsTracking {
    static let shared = InputAnalyticsTracker()
    private let mixPanelToken: String
    
    private init() {
        self.mixPanelToken = APIConfig.mixPanelToken
        Mixpanel.initialize(token: self.mixPanelToken, trackAutomaticEvents: true)
    }

    func trackEvent(_ eventName: String, properties: [String: MixpanelType]? = nil) {
        Mixpanel.mainInstance().track(
            event: eventName,
            properties: properties
        )
    }

    
    func requestSpeechAuthorization() {
            SFSpeechRecognizer.requestAuthorization { authStatus in
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        self.trackEvent("Speech Recognition Authorized", properties: nil)
                    case .denied:
                        self.trackEvent("Speech Recognition Denied", properties: nil)
                    case .restricted:
                        self.trackEvent("Speech Recognition Restricted", properties: nil)
                    case .notDetermined:
                        self.trackEvent("Speech Recognition Not Determined", properties: nil)
                    @unknown default:
                        self.trackEvent("Speech Recognition Unknown Status", properties: nil)
                    }
                }
            }
        }
    
    func trackInputStarted(type: InputType, date: Date) {
        Mixpanel.mainInstance().track(
            event: "\(type.name) Input Started",
            properties: [
                "timestamp": Date().timeIntervalSince1970,
                "selected_date": date.timeIntervalSince1970,
                "weekday": Calendar.current.component(.weekday, from: date)
            ]
        )
    }
    
    func trackInputCompleted(type: InputType, success: Bool, duration: TimeInterval? = nil, textLength: Int) {
        var properties: [String: MixpanelType] = [
            "success": success,
            "text_length": textLength,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let duration = duration {
            properties["duration_seconds"] = duration
        }
        
        Mixpanel.mainInstance().track(
            event: "\(type.name) Input Completed",
            properties: properties
        )
    }
    
    func trackInputCancelled(type: InputType) {
        Mixpanel.mainInstance().track(
            event: "\(type.name) Input Cancelled",
            properties: [
                "timestamp": Date().timeIntervalSince1970
            ]
        )
    }
    
    func trackProcessingStarted(type: InputType) {
        Mixpanel.mainInstance().track(
            event: "\(type.name) Processing Started",
            properties: [
                "timestamp": Date().timeIntervalSince1970
            ]
        )
    }
    
    func trackProcessingCompleted(type: InputType, success: Bool, studentsCount: Int) {
        Mixpanel.mainInstance().track(
            event: "\(type.name) Processing Completed",
            properties: [
                "success": success,
                "students_count": studentsCount,
                "timestamp": Date().timeIntervalSince1970
            ]
        )
    }
}
