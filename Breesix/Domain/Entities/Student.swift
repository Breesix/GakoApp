//
//  Student.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Student {
    var id: UUID = UUID()
    var fullname: String
    var nickname: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Note.student) var notes: [Note] = []
    @Relationship(deleteRule: .cascade, inverse: \Activity.student) var activities: [Activity] = []
    @Attribute(.externalStorage) var imageData: Data?
    
    init(id: UUID = UUID(), fullname: String, nickname: String, createdAt: Date = Date(), imageData: Data? = nil) {
        self.id = id
        self.fullname = fullname
        self.nickname = nickname
        self.createdAt = createdAt
        self.imageData = imageData
    }
    
    var image: Image? {
        guard let imageData = imageData else { return nil }
        return Image(uiImage: UIImage(data: imageData) ?? UIImage())
    }
}
