//
//  ActivityDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation
import SwiftData

class ActivityDataSourceImpl: ActivityDataSource {
    private let modelContext: ModelContext
    
    init(context: ModelContext) {
        self.modelContext = context
    }
    
    func fetchActivities(_ student: Student) async throws -> [Activity] {
        return student.activities
    }
    
    func insert(_ activity: Activity, for student: Student) async throws {
        student.activities.append(activity)
        try modelContext.save()
    }
    
    func update(_ activity: Activity) async throws {
        try modelContext.save()
    }
    
    func delete(_ activity: Activity, from student: Student) async throws {
        student.activities.removeAll { $0.id == activity.id }
        modelContext.delete(activity)
        try modelContext.save()
    }
}

