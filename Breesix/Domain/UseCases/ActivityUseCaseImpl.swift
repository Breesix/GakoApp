//
//  ActivityUseCaseImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation

struct ActivityUseCaseImpl: ActivityUseCase {
    let repository: ActivityRepository

    func fetchAllActivities(_ student: Student) async throws -> [Activity] {
        return try await repository.fetchAllActivities(student)
    }

    func addActivity(_ activity: Activity, for student: Student) async throws {
        try await repository.addActivity(activity, for: student)
    }
    
    func updateActivity(_ activity: Activity) async throws {
        try await repository.updateActivity(activity)
    }
    
    func deleteActivity(_ activity: Activity, from student: Student) async throws {
        try await repository.deleteActivity(activity, from: student)
    }
}

