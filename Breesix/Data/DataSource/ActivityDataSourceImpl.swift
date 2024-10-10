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

    func fetchAllActivities() async throws -> [Activity] {
        do {
            let descriptor = FetchDescriptor<Activity>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let activities = try await Task { @MainActor in
                try modelContext.fetch(descriptor)
            }.value
            return activities
        } catch {
            throw ActivityDataSourceError.failedToFetchActivities(error)
        }
    }

    func insert(_ activity: Activity) async throws {
        do {
            modelContext.insert(activity)
            try modelContext.save()
        } catch {
            throw ActivityDataSourceError.failedToInsertActivity(error)
        }
    }

    func update(_ activity: Activity) async throws {
        do {
            try modelContext.save()
        } catch {
            throw ActivityDataSourceError.failedToUpdateActivity(error)
        }
    }

    func delete(_ activity: Activity) async throws {
        do {
            modelContext.delete(activity)
            try modelContext.save()
        } catch {
            throw ActivityDataSourceError.failedToDeleteActivity(error)
        }
    }
}

enum ActivityDataSourceError: Error {
    case failedToFetchActivities(Error)
    case failedToInsertActivity(Error)
    case failedToUpdateActivity(Error)
    case failedToDeleteActivity(Error)
}
