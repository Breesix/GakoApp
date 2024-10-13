//
//  ToiletTrainingRepositoryImpl.swift
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

    func addActivity(_ toiletTraining: Activity, for student: Student) async throws {
        if let index = student.activities.firstIndex(where: { $0.createdAt == toiletTraining.createdAt }) {
            student.activities[index] = toiletTraining
                } else {
                }
        student.activities.append(toiletTraining)

        try await dataSource.insert(toiletTraining)
    }
        
    func updateActivity(_ toiletTraining: Activity) async throws {
        try await dataSource.update(toiletTraining)
    }
    
    func deleteActivity(_ toiletTraining: Activity, from student: Student) async throws {
        student.activities.removeAll(where: { $0.id == toiletTraining.id })
        try await dataSource.delete(toiletTraining)
    }

}
