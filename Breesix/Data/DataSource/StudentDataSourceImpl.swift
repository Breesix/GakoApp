//
//  StudentDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData

class StudentDataSourceImpl: StudentDataSource {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchAllStudents() async throws -> [Student] {
        // Ensure context usage on the main actor to prevent threading issues
        return try await Task { @MainActor in
            let descriptor = FetchDescriptor<Student>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let students = try context.fetch(descriptor)
            return students
        }.value
    }

    func insert(_ student: Student) async throws {
        context.insert(student)
        try context.save()
    }
    
    func update(_ student: Student) async throws {
        try context.save()
    }
    
    func delete(_ student: Student) async throws {
        for activity in student.activities {
            context.delete(activity)
        }
        
        student.activities.removeAll()
        context.delete(student)
        try context.save()
    }
}

