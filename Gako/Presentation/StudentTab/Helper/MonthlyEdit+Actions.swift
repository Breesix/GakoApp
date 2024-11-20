//
//  MonthlyEdit+Actions.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides action handlers for MonthlyEditCard
//  Usage: Contains methods for handling status updates in monthly edit view
//

import Foundation

extension MonthlyEditCard {
    // MARK: - Status Actions
    func handleStatusChange(activity: Activity, newStatus: Status) {
        Task {
            await viewModel.updateActivityStatus(
                activity: activity,
                newStatus: newStatus,
                onUpdateActivityStatus: onUpdateActivityStatus
            )
        }
    }
}
