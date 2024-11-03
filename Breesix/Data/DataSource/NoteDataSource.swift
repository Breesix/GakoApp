//
//  NoteDataSource.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation

protocol NoteDataSource {
    func fetchAllNotes(_ student: Student) async throws -> [Note]
    func insert(_ note: Note, for student: Student) async throws
    func update(_ note: Note) async throws
    func delete(_ note: Note, from student: Student) async throws
}

