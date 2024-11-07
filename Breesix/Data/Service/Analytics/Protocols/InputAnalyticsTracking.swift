//
//  InputAnalyticsTracking.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24
//
import Foundation
import SwiftUI
import Mixpanel


protocol InputAnalyticsTracking {
    func trackInputStarted(type: InputType, date: Date)
    func trackInputCompleted(type: InputType, success: Bool, duration: TimeInterval?, textLength: Int)
    func trackInputCancelled(type: InputType)
    func trackProcessingStarted(type: InputType)
    func trackProcessingCompleted(type: InputType, success: Bool, studentsCount: Int)
    func trackEvent(_ eventName: String, properties:[String: MixpanelType]?)
}

protocol AnalyticsEvent {
    var name: AnalyticsEventType { get }
    var properties: [String: MixpanelType] { get }
}


// Buat struct untuk setiap jenis event
struct InputEvent: AnalyticsEvent {
    let name: AnalyticsEventType
    let properties: [String: MixpanelType]
    
    init(
        type: AnalyticsEventType,
        inputType: InputType,
        success: Bool? = nil,
        duration: TimeInterval? = nil,
        textLength: Int? = nil,
        studentsCount: Int? = nil
    ) {
        self.name = type
        var props: [String: MixpanelType] = [
            "input_type": inputType.rawValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let success = success {
            props["success"] = success
        }
        if let duration = duration {
            props["duration_seconds"] = duration
        }
        if let textLength = textLength {
            props["text_length"] = textLength
        }
        if let studentsCount = studentsCount {
            props["students_count"] = studentsCount
        }
        
        self.properties = props
    }
}


