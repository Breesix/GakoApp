//
//  LessonPlanTemplate.swift
//  Breesix
//
//  Created by Akmal Hakim on 24/09/24.
//

import Foundation

struct Activity: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String
    var days: [String] // Example: ["Monday", "Wednesday"]
}

struct WeeklyTemplate: Identifiable, Codable {
    let id: String
    var alphaNumCode: String
    var title: String
    var lessons: [Activity]
}
