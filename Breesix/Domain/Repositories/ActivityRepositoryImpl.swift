//
//  ActivityRepositoryImpl.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//
import Foundation
import SwiftData

class ActivityRepositoryImpl: ActivityRepository {
    private let dataSource: ActivityDataSource

    init(activityDataSource: ActivityDataSource) {
        self.dataSource = activityDataSource
    }

    func fetchActivities(_ student: Student) async throws -> [Activity] {
        return student.activities
    }

    func addActivity(_ activity: Activity, for student: Student) async throws {
        student.activities.append(activity)
        try await dataSource.insert(activity)
    }
        
    func updateActivity(_ activity: Activity) async throws {
        try await dataSource.update(activity)
    }
    
    func deleteActivity(_ activity: Activity, from student: Student) async throws {
        student.activities.removeAll(where: { $0.id == activity.id })
        try await dataSource.delete(activity)
    }

}
