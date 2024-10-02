//
//  GeneralActivityRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation

protocol GeneralActivityRepository {
    func addActivity(_ activity: Activity, for student: Student) async throws
    func getActivitiesForStudent(_ student: Student) async throws -> [Activity]
    func updateActivity(_ activity: Activity) async throws
    func deleteActivity(_ activity: Activity, from student: Student) async throws
}
