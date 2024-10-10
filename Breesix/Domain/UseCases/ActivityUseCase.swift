//
//  GeneralActivityUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation

struct ActivityUseCase {
    let repository: ActivityRepository

    func addActivity(_ activity: Activity, for student: Student) async throws {
        try await repository.addActivity(activity, for: student)
    }

    func getActivitiesForStudent(_ student: Student) async throws -> [Activity] {
        return try await repository.getActivitiesForStudent(student)
    }
    
    func updateActivity(_ activity: Activity) async throws {
        try await repository.updateActivity(activity)
    }
    
    func deleteActivity(_ activity: Activity, from student: Student) async throws {
        try await repository.deleteActivity(activity, from: student)
    }
}

