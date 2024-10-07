//
//  WeeklySummary.swift
//  Breesix
//
//  Created by Rangga Biner on 07/10/24.
//

import Foundation
import SwiftData

@Model
class WeeklySummary: Identifiable {
    var id: UUID = UUID()
    var startDate: Date
    var endDate: Date
    var summary: String
    @Relationship(deleteRule: .nullify) var student: Student?

    init(id: UUID = UUID(), startDate: Date, endDate: Date, summary: String, student: Student? = nil) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.student = student
    }
}
