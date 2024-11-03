//
//  Activity.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import SwiftData

enum Status: String, Codable {
    case mandiri = "mandiri"
    case dibimbing = "dibimbing"
    case tidakMelakukan = "tidak melakukan"
}
@Model
class Activity {
    @Attribute(.unique) var id: UUID
    var activity: String
    var createdAt: Date
    var status: Bool?
    weak var student: Student?
    
    init(id: UUID = UUID(), activity: String, createdAt: Date = Date(), status: Bool? = nil, student: Student) {
        self.id = id
        self.activity = activity
        self.createdAt = createdAt
        self.status = status
        self.student = student
    }
}

class UnsavedActivity: Identifiable {
    var id: UUID
    var activity: String
    var createdAt: Date
    var status: Bool? 
    var studentId: Student.ID
    
    init(id: UUID = UUID(), activity: String, createdAt: Date, status: Bool? = nil, studentId: Student.ID) {
        self.id = id
        self.activity = activity
        self.createdAt = createdAt
        self.status = status
        self.studentId = studentId
    }
}
