//
//  Student.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//

import Foundation

struct Student: Identifiable {
    var id: String
    var nisn: String
    var name: String
    var gender: String
    var birthdate: Date // Update to accept Date instead of String
    var background: String
    var emergencyContact: String
    var autismLevel: String
    var likes: String
    var dislikes: String
    var skills: String
    var imageUrl: String?
}

