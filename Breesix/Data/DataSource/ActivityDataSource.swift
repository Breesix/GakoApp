//
//  ActivityDataSource.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation

protocol ActivityDataSource {
    func fetchAllActivities() async throws -> [Activity]
    func insert(_ activity: Activity) async throws
    func update(_ activity: Activity) async throws
    func delete(_ activity: Activity) async throws
}
