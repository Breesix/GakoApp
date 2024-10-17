//
//  Activity.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import SwiftData

@Model
class Activity: Identifiable {
    @Attribute(.unique) var id: UUID
    var activity: String
    var createdAt: Date
    var isIndependent: Bool?
    var student: Student?
    
    init(id: UUID = UUID(), activity: String, createdAt: Date = Date(), isIndependent: Bool? = nil, student: Student? = nil) {
        self.id = UUID()
        self.activity = activity
        self.createdAt = createdAt
        self.isIndependent = isIndependent
        self.student = student
    }
}

class UnsavedActivity: Identifiable {
    var id: UUID
    var activity: String
    var createdAt: Date
    var isIndependent: Bool? 
    var studentId: Student.ID
    
    init(id: UUID = UUID(), activity: String, createdAt: Date = Date(), isIndependent: Bool? = nil, studentId: Student.ID) {
        self.id = UUID()
        self.activity = activity
        self.createdAt = createdAt
        self.isIndependent = isIndependent
        self.studentId = studentId
    }
}
