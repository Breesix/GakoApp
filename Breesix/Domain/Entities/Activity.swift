//
//  ToiletTraining.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import SwiftData

@Model
class Activity: Identifiable {
    var id: UUID
    var activity: String
    var createdAt: Date
    var isIndependent: Bool?
    var student: Student?
    
    init(id: UUID = UUID(), trainingDetail: String, createdAt: Date = Date(), status: Bool? = nil, student: Student? = nil) {
        self.id = id
        self.activity = trainingDetail
        self.createdAt = createdAt
        self.isIndependent = status
        self.student = student
    }
}

class UnsavedActivity: Identifiable {
    var id: UUID
    var activity: String
    var createdAt: Date
    var isIndependent: Bool?
    var studentId: Student.ID
    
    init(id: UUID = UUID(), trainingDetail: String, createdAt: Date = Date(), status: Bool? = nil, studentId: Student.ID) {
        self.id = id
        self.activity = trainingDetail
        self.createdAt = createdAt
        self.isIndependent = status
        self.studentId = studentId
    }
    
}
