//
//  ToiletTrainingDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation
import SwiftData

class ToiletTrainingDataSourceImpl: ToiletTrainingDataSource {
    
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }

    func fetchAllToiletTrainings() async throws -> [ToiletTraining] {
        do {
            let descriptor = FetchDescriptor<ToiletTraining>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let toiletTrainings = try await Task { @MainActor in
                try modelContext.fetch(descriptor)
            }.value
            return toiletTrainings
        } catch {
            throw ToiletTrainingDataSourceError.failedToFetchToiletTraining(error)
        }
    }

    func insert(_ toiletTraining: ToiletTraining) async throws {
        do {
            modelContext.insert(toiletTraining)
            try modelContext.save()
        } catch {
            throw ToiletTrainingDataSourceError.failedToInsertToiletTraining(error)
        }
    }

    func update(_ toiletTraining: ToiletTraining) async throws {
        do {
            try modelContext.save()
        } catch {
            throw ToiletTrainingDataSourceError.failedToUpdateToiletTraining(error)
        }
    }

    func delete(_ toiletTraining: ToiletTraining) async throws {
        do {
            modelContext.delete(toiletTraining)
            try modelContext.save()
        } catch {
            throw ToiletTrainingDataSourceError.failedToDeleteToiletTraining(error)
        }
    }
}

enum ToiletTrainingDataSourceError: Error {
    case failedToFetchToiletTraining(Error)
    case failedToInsertToiletTraining(Error)
    case failedToUpdateToiletTraining(Error)
    case failedToDeleteToiletTraining(Error)
}
