//
//  NoteRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation
import SwiftData

class NoteRepositoryImpl: NoteRepository {
    private let dataSource: NoteDataSource

    init(dataSource: NoteDataSource) {
        self.dataSource = dataSource
    }

    func fetchAllNotes(_ student: Student) async throws -> [Note] {
        return student.notes
    }

    func addNote(_ note: Note, for student: Student) async throws {
        student.notes.append(note)
        try await dataSource.insert(note)
    }

    func updateNote(_ note: Note) async throws {
        try await dataSource.update(note)
    }

    func deleteNote(_ note: Note, from student: Student) async throws {
        student.notes.removeAll { $0.id == note.id }
        try await dataSource.delete(note)
    }
}
