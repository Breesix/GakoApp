//
//  NoteUseCaseImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation

struct NoteUseCaseImpl: NoteUseCase {
    let repository: NoteRepository

    func fetchAllNotes(_ student: Student) async throws -> [Note] {
        return try await repository.fetchAllNotes(student)
    }

    func addNote(_ note: Note, for student: Student) async throws {
        try await repository.addNote(note, for: student)
    }
    
    func updateNote(_ note: Note) async throws {
        try await repository.updateNote(note)
    }
    
    func deleteNote(_ note: Note, from student: Student) async throws {
        try await repository.deleteNote(note, from: student)
    }
}

