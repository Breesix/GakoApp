//
//  StudentRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

protocol StudentRepository {
    func getAllStudents() async throws -> [Student]
    func addStudent(_ student: Student) async throws
    func updateStudent(_ student: Student) async throws
    func deleteStudent(_ student: Student) async throws
}
