//
//  Activity.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData

@Model
class Note {
    var id: UUID = UUID()
    var note: String
    var createdAt: Date
    var student: Student?

    init(id: UUID = UUID(), note: String, createdAt: Date = Date(), student: Student? = nil) {
        self.id = id
        self.note = note
        self.createdAt = createdAt
        self.student = student
    }
}

struct UnsavedNote: Identifiable {
    var id: UUID
    var note: String
    var createdAt: Date
    var studentId: Student.ID 

    init(id: UUID = UUID(), note: String, createdAt: Date, studentId: Student.ID) {
        self.id = id
        self.note = note
        self.createdAt = createdAt
        self.studentId = studentId
    }
}

enum InputType {
    case speech
    case manual
}

