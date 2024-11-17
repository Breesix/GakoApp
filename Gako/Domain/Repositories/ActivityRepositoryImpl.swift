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
    
    init(dataSource: ActivityDataSource) {
        self.dataSource = dataSource
    }
    
    func fetchActivities(_ student: Student) async throws -> [Activity] {
        return try await dataSource.fetchActivities(student)
    }
    
    func addActivity(_ activity: Activity, for student: Student) async throws {
        try await dataSource.insert(activity, for: student)
    }
    
    func updateActivity(_ activity: Activity) async throws {
        try await dataSource.update(activity)
    }
    
    func deleteActivity(_ activity: Activity, from student: Student) async throws {
        try await dataSource.delete(activity, from: student)
    }
}

