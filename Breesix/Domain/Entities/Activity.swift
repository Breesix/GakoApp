//
//  Note.swift
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
    @Relationship(deleteRule: .nullify) var student: Student?

    init(id: UUID = UUID(), generalActivity: String, createdAt: Date = Date(), student: Student? = nil) {
        self.id = id
        self.generalActivity = generalActivity
        self.createdAt = createdAt
        self.student = student
    }
}
