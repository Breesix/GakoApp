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

    func fetchAllStudents() async throws -> [Student] {
        do {
            let descriptor = FetchDescriptor<Student>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
            let students = try await Task { @MainActor in
                try modelContext.fetch(descriptor)
            }.value
            return students
        } catch {
            throw StudentDataSourceError.failedToFetchStudents(error)
        }
    }

    func insert(_ student: Student) async throws {
        do {
            modelContext.insert(student)
            try modelContext.save()
        } catch {
            throw StudentDataSourceError.failedToInsertStudent(error)
        }
    }

    func update(_ student: Student) async throws {
        do {
            try modelContext.save()
        } catch {
            throw StudentDataSourceError.failedToUpdateStudent(error)
        }
    }
    
    func delete(_ student: Student) async throws {
        do {
            for activity in student.activities {
                modelContext.delete(activity)
            }
            for training in student.toiletTrainings {
                modelContext.delete(training)
            }
            student.activities.removeAll()
            student.toiletTrainings.removeAll()
            modelContext.delete(student)
            try modelContext.save()
        } catch {
            throw StudentDataSourceError.failedToDeleteStudent(error)
        }
    }
}

enum StudentDataSourceError: Error {
    case failedToFetchStudents(Error)
    case failedToInsertStudent(Error)
    case failedToUpdateStudent(Error)
    case failedToDeleteStudent(Error)
}
