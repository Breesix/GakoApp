//
//  StudentUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

struct StudentUseCase {
    let repository: StudentRepository
    
    func getAllStudents() async throws -> [Student] {
        return try await repository.getAllStudents()
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

