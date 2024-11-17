//
//  Onboarding.swift
//  Breesix
//
//  Created by Kevin Fairuz on 05/11/24.
//
//  A model for onboarding item that have more than one items
//  Usage: Use this model for create onboarding item
//


import Foundation

struct Onboarding: Identifiable {
    var id: UUID
    var lottie: String
    var title: String
    var description: String
    
    init(id: UUID = UUID(), lottie: String, title: String, description: String) {
        self.id = id
        self.lottie = lottie
        self.title = title
        self.description = description
    }
}
