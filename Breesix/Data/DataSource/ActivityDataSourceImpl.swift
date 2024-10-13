//
//  ActivityDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation
import SwiftData

class ActivityDataSourceImpl: ActivityDataSource {
    
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }

    func fetch() async throws -> [Activity] {
        let descriptor = FetchDescriptor<Activity>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let activities = try modelContext.fetch(descriptor)
        return activities
    }

    func insert(_ activity: Activity) async throws {
            modelContext.insert(activity)
        try modelContext.save()
    }

    func update(_ activity: Activity) async throws {
        try modelContext.save()
    }

    func delete(_ activity: Activity) async throws {
        modelContext.delete(activity)
        try modelContext.save()
    }
}
