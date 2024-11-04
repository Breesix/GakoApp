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



