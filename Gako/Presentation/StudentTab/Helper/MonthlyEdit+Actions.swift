//
//  MonthlyEdit+Actions.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
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
