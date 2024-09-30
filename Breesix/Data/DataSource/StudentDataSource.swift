//
//  StudentDataSource.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

protocol StudentDataSource {
    func fetchAllStudents() async throws -> [Student]
    func insert(_ student: Student) async throws
    func update(_ student: Student) async throws
    func delete(_ student: Student) async throws
}

