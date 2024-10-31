//
//  Summary.swift
//  Breesix
//
//  Created by Rangga Biner on 18/10/24.
//

import Foundation
import SwiftData


@Model
class Summary {
    @Attribute(.unique) var id: UUID
    var summary: String
    var createdAt: Date
    weak var student: Student?

    init(id: UUID = UUID(), summary: String, createdAt: Date = Date(), student: Student) {
        self.id = id
        self.summary = summary
        self.createdAt = createdAt
        self.student = student
    }
}
