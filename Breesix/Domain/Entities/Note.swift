//
//  Note.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData

@Model
class Note {
    var id: UUID = UUID()
    var generalActivity: String
    var toiletTraining: String
    var toiletTrainingStatus: Bool
    var createdAt: Date
    @Relationship(deleteRule: .nullify) var student: Student?

    init(id: UUID = UUID(), generalActivity: String, toiletTraining: String, toiletTrainingStatus: Bool, createdAt: Date = Date(), student: Student? = nil) {
        self.id = id
        self.generalActivity = generalActivity
        self.toiletTraining = toiletTraining
        self.toiletTrainingStatus = toiletTrainingStatus
        self.createdAt = createdAt
        self.student = student
    }
}
