//
//  Activity.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData

@Model
class Activity {
    var id: UUID = UUID()
    var generalActivity: String
    var createdAt: Date
    var student: Student?

    init(id: UUID = UUID(), generalActivity: String, createdAt: Date = Date(), student: Student? = nil) {
        self.id = id
        self.generalActivity = generalActivity
        self.createdAt = createdAt
        self.student = student
    }
}

struct UnsavedActivity: Identifiable {
    var id: UUID
    var generalActivity: String
    var createdAt: Date
    var studentId: Student.ID 

    init(id: UUID = UUID(), generalActivity: String, createdAt: Date, studentId: Student.ID) {
        self.id = id
        self.generalActivity = generalActivity
        self.createdAt = createdAt
        self.studentId = studentId
    }
}

enum InputType {
    case speech
    case manual
}

