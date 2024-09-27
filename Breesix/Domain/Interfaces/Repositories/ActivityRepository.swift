//
//  ActivityRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 27/09/24.
//

import Foundation

class ActivityRepository {
    private var activities: [Activity] = [
        Activity(title: "Upacara"),
        Activity(title: "Memasak"),
        Activity(title: "Menari"),
    ]
    
    func getAllActivities() -> [Activity] {
        return activities
    }
}
