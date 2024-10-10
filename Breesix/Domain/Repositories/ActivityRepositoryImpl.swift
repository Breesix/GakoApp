//
//  GeneralActivityRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation
import SwiftData

class ActivityRepositoryImpl: ActivityRepository {
    private let activityDataSource: ActivityDataSource
    private let studentDataSource: StudentDataSource

    init(activityDataSource: ActivityDataSource, studentDataSource: StudentDataSource) {
        self.activityDataSource = activityDataSource
        self.studentDataSource = studentDataSource
    }

    func fetchAllActivities(_ student: Student) async throws -> [Activity] {
        return student.activities
    }

    func addActivity(_ activity: Activity, for student: Student) async throws {
        student.activities.append(activity)
        try await activityDataSource.insert(activity)
    }

    func updateActivity(_ activity: Activity) async throws {
        try await activityDataSource.update(activity)
    }

    func deleteActivity(_ activity: Activity, from student: Student) async throws {
        student.activities.removeAll { $0.id == activity.id }
        try await activityDataSource.delete(activity)
    }
}
