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
    var createdAt: Date // Property to store creation date
    var title: String // New property to store title
    @Relationship(deleteRule: .nullify) var student: Student?

    init(id: UUID = UUID(), startDate: Date, endDate: Date, summary: String, createdAt: Date = Date(), title: String, student: Student? = nil) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.summary = summary
        self.createdAt = createdAt // Initialize createdAt
        self.title = title // Initialize title
        self.student = student
    }
}
