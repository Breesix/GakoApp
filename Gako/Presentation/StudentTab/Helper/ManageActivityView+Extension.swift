//
//  ManageActivityView+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//

import Foundation
import Mixpanel

extension ManageActivityView {
    enum Mode: Equatable {
        case add
        case edit(Activity)
        
        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.add, .add):
                return true
            case let (.edit(activity1), .edit(activity2)):
                return activity1.id == activity2.id
            default:
                return false
            }
        }
    }
    func saveActivity() {
        switch mode {
        case .add:
            let newActivity = Activity(
                activity: activityText,
                createdAt: selectedDate,
                status: selectedStatus,
                student: student
            )
            
            trackActivityCreation(newActivity)
            
            Task {
                await onSave(newActivity)
                onDismiss()
            }
            
        case .edit(let activity):
            let updatedActivity = activity
            updatedActivity.activity = activityText
            onUpdate(updatedActivity)
            onDismiss()
        }
    }
    
    func trackActivityCreation(_ activity: Activity) {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_text_length": activityText.count,
            "status": selectedStatus.rawValue,
            "created_at": selectedDate.timeIntervalSince1970,
            "screen": "add_activity",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Created", properties: properties)
    }
}
