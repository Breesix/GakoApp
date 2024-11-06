//
//  ActivityDataSource.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation

protocol ActivityDataSource {
    func fetchActivities(_ student: Student) async throws -> [Activity]
    func insert(_ activity: Activity, for student: Student) async throws
    func update(_ activity: Activity) async throws
    func delete(_ activity: Activity, from student: Student) async throws
}

