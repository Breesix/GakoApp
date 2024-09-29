//
//  Student.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData

@Model
class Student {
    var id: UUID = UUID()
    var fullname: String
    var nickname: String
    var createdAt: Date
    
    init(id: UUID = UUID(), fullname: String, nickname: String, createdAt: Date = Date()) {
        self.id = id
        self.fullname = fullname
        self.nickname = nickname
        self.createdAt = createdAt
    }
}
