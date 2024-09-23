//
//  DailyActivity.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import Foundation

struct DailyActivity: Identifiable {
    var id: String
    var date: Date
    var summary: String // A short summary of the activity
    var fullLog: String // Full detailed log of the activity
}
