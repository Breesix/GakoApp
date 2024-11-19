//
//  EditActivitySection+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import Foundation
import SwiftUI

extension EditActivitySection {
    // MARK: - Binding Helpers
    func binding(for activity: Activity) -> Binding<Activity> {
        Binding(
            get: { activity },
            set: { newValue in
                onActivityUpdate(newValue)
            }
        )
    }
    
    // MARK: - Validation
    func hasActivities() -> Bool {
        return !activities.isEmpty
    }
    
    func isValidActivity(_ activity: Activity) -> Bool {
        return !activity.activity.isEmpty
    }
}
