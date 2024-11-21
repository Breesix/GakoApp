//
//  DailyReportCard+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension for DailyReportCard that provides validation logic before sharing the daily report.
//  Usage: This extension is automatically available to DailyReportCard.
//

import Foundation

extension DailyReportCard {
    // MARK: - Validate
    func validateAndShare() {
        if activities.isEmpty && notes.isEmpty {
            showEmptyAlert = true
            return
        }
        onShareTapped(date)
    }
}
