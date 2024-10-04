//
//  ToiletTraining.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import SwiftData

@Model
class ToiletTraining: Identifiable {
    var id: UUID
    var trainingDetail: String
    var createdAt: Date
    var status: Bool?
    @Relationship(deleteRule: .nullify) var student: Student?
    
    init(id: UUID = UUID(), trainingDetail: String, createdAt: Date = Date(), status: Bool? = nil, student: Student? = nil) {
        self.id = id
        self.trainingDetail = trainingDetail
        self.createdAt = createdAt
        self.status = status
        self.student = student
    }
    
}

class UnsavedToiletTraining: Identifiable {
    var id: UUID
    var trainingDetail: String
    var createdAt: Date
    var status: Bool?
    var studentId: Student.ID
    
    init(id: UUID = UUID(), trainingDetail: String, createdAt: Date = Date(), status: Bool? = nil, studentId: Student.ID) {
        self.id = id
        self.trainingDetail = trainingDetail
        self.createdAt = createdAt
        self.status = status
        self.studentId = studentId
    }
    
}
