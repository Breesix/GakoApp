//
//  ToiletTraining.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import SwiftData

@Model
class ToiletTraining {
    var id: UUID = UUID()
    var trainingDetail: String
    var createdAt: Date
    var status: Bool?
    @Relationship(deleteRule: .nullify) var student: Student?

    init(id: UUID = UUID(), trainingDetail: String, createdAt: Date = Date(), student: Student? = nil, status: Bool = false) {
        self.id = id
        self.trainingDetail = trainingDetail
        self.createdAt = createdAt
        self.student = student
        self.status = status
    }
}
