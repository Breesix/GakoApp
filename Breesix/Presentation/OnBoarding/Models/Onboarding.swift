//
//  Onboarding.swift
//  Gako
//
//  Created by Kevin Fairuz on 05/11/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: A model for onboarding item that have more than one item
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
