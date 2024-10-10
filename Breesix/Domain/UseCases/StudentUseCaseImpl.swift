//
//  StudentUseCaseImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation

struct StudentUseCaseImpl: StudentUseCase {
    let repository: StudentRepository
    
    func fetchAllStudents() async throws -> [Student] {
        return try await repository.fetchAllStudents()
    }
    
    func addStudent(_ student: Student) async throws {
        try await repository.addStudent(student)
    }
    
    func updateStudent(_ student: Student) async throws {
        try await repository.updateStudent(student)
    }
    
    func deleteStudent(_ student: Student) async throws {
        try await repository.deleteStudent(student)
    }
}

