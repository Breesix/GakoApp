//
//  InputAnalyticsEvent.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//


// MARK: - Services/Analytics/Models/InputAnalyticsEvent.swift
enum AnalyticsEventType: String {
    // Input Events
    case voiceInputStarted = "Voice Input Started"
    case voiceInputCompleted = "Voice Input Completed"
    case textInputStarted = "Text Input Started"
    case textInputCompleted = "Text Input Completed"
    
    // Activity Events
    case activityCreated = "Activity Created"
    case activityUpdated = "Activity Updated"
    case activityDeleted = "Activity Deleted"
    case activitySaved = "Activities Saved"
    
    // Note Events
    case noteCreated = "Note Created"
    case noteUpdated = "Note Updated"
    case noteDeleted = "Note Deleted"
    case noteSaved = "Notes Saved"
    
    // Preview Events
    case previewOpened = "Preview Opened"
    case previewClosed = "Preview Closed"
}
