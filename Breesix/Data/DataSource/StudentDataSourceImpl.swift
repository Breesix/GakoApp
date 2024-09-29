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
        let descriptor = FetchDescriptor<Student>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let students = try context.fetch(descriptor)
        print("Fetched \(students.count) students")
        return students
    }

    func insert(_ student: Student) async throws {
        context.insert(student)
        try context.save()
    }
    
    func update(_ student: Student) async throws {
        try context.save()
    }
    
    func delete(_ student: Student) async throws {
        context.delete(student)
        try context.save()
    }
}

