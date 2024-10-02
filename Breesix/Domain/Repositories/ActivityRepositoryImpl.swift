//
//  GeneralActivityRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation
import SwiftData

class ActivityRepositoryImpl: ActivityRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addActivity(_ activity: Activity, for student: Student) async throws {
        student.activities.append(activity)
        try context.save()
    }

    func getActivitiesForStudent(_ student: Student) async throws -> [Activity] {
        return student.activities
    }
    
    func updateActivity(_ activity: Activity) async throws {
        try context.save()
    }
    
    func deleteActivity(_ activity: Activity, from student: Student) async throws {
        student.activities.removeAll { $0.id == activity.id }
        context.delete(activity)
        try context.save()
    }

}
