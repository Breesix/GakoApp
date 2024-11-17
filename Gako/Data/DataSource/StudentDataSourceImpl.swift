//
//  StudentDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData

class StudentDataSourceImpl: StudentDataSource {
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }
    
    @MainActor
    func fetch() async throws -> [Student] {
        let descriptor = FetchDescriptor<Student>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func insert(_ student: Student) async throws {
        modelContext.insert(student)
        try modelContext.save()
    }

    func update(_ student: Student) async throws {
        try modelContext.save()
    }

    func delete(_ student: Student) async throws {
        modelContext.delete(student)
        try modelContext.save()
    }
}
