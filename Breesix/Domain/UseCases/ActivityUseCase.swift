//
//  GeneralActivityUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation

protocol ActivityUseCase {
    func fetchAllActivities(_ student: Student) async throws -> [Activity]
    func addActivity(_ activity: Activity, for student: Student) async throws
    func updateActivity(_ activity: Activity) async throws
    func deleteActivity(_ activity: Activity, from student: Student) async throws
}

