//
//  DailyReportTemplate+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides logical operations for DailyReportTemplate
//  Usage: Contains helper methods for date formatting and page calculations
//

import Foundation

extension DailyReportTemplate {
    func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func calculateRequiredPages() -> Int {
        let activitiesPages = ceil(Double(max(0, activities.count - 5)) / 10.0)
        let notesPages = ceil(Double(notes.count) / 5.0)
        return 1 + Int(max(activitiesPages, notesPages))
    }
    
    func getPageActivities(pageIndex: Int) -> [Activity] {
        if pageIndex == 0 {
            return Array(activities.prefix(6))
        } else {
            let startIndex = 5 + (pageIndex - 1) * 10
            return Array(activities.dropFirst(startIndex).prefix(10))
        }
    }
    
    func getPageNotes(pageIndex: Int) -> [Note] {
        let notesStartIndex = (pageIndex - 1) * 5
        return Array(notes.dropFirst(notesStartIndex).prefix(5))
    }
}
