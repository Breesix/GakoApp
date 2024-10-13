//
//  ActivityUseCase.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation

protocol ActivityUseCase {
    func fetchActivities(_ student: Student) async throws -> [Activity]
    func addActivity(_ activity: Activity, for student: Student) async throws
    func updateActivity(_ activity: Activity) async throws
    func deleteActivity(_ activity: Activity, from student: Student) async throws
}
