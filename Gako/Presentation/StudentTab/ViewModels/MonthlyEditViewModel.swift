//
//  MonthlyEditViewModel.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

@MainActor
class MonthlyEditViewModel: ObservableObject {
    private let service = MonthlyEditService()
    
    // MARK: - Activity Management
    func updateActivityStatus(
        activity: Activity,
        newStatus: Status,
        onUpdateActivityStatus: @escaping (Activity, Status) async -> Void
    ) async {
        await service.updateActivityStatus(
            activity: activity,
            newStatus: newStatus,
            onUpdateActivityStatus: onUpdateActivityStatus
        )
    }
    
    // MARK: - Note Management
    func addEmptyNote(onAddNote: (String) -> Void) {
        onAddNote("")
    }
}
