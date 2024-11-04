//
//  InputAnalyticsEvent.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//


// MARK: - Services/Analytics/Models/InputAnalyticsEvent.swift
enum InputAnalyticsEvent: String {
    case inputStarted = "Input Started"
    case inputCompleted = "Input Completed"
    case inputCancelled = "Input Cancelled"
    case processingStarted = "Processing Started"
    case processingCompleted = "Processing Completed"
}