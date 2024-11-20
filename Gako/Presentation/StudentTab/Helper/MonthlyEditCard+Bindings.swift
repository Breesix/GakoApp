//
//  MonthlyEditCard+Bindings.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides binding creation methods for MonthlyEditCard
//  Usage: Contains helper methods for creating activity value and status bindings
//

import Foundation
import SwiftUI

extension MonthlyEditCard {
    // MARK: - Binding Helpers
    func makeValueBinding(for activity: Activity) -> Binding<String> {
        MonthlyEditHelper.makeActivityValueBinding(
            activity: activity,
            editedActivities: $editedActivities,
            date: date
        )
    }
    
    func makeStatusBinding(for activity: Activity) -> Binding<Status> {
        MonthlyEditHelper.makeActivityStatusBinding(
            activity: activity,
            editedActivities: $editedActivities,
            date: date
        )
    }
}
