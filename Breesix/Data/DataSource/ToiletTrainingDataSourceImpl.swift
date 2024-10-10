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

    func fetch() async throws -> [ToiletTraining] {
        let descriptor = FetchDescriptor<ToiletTraining>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let toiletTrainings = try modelContext.fetch(descriptor)
        return toiletTrainings
    }

    func insert(_ toiletTraining: ToiletTraining) async throws {
            modelContext.insert(toiletTraining)
        try modelContext.save()
    }

    func update(_ toiletTraining: ToiletTraining) async throws {
        try modelContext.save()
    }

    func delete(_ toiletTraining: ToiletTraining) async throws {
        modelContext.delete(toiletTraining)
        try modelContext.save()
    }
}
