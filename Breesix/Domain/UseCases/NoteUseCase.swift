//
//  NoteUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

struct NoteUseCase {
    let repository: NoteRepository

    func addNote(_ note: Note, for student: Student) async throws {
        try await repository.addNote(note, for: student)
    }

    func getNotesForStudent(_ student: Student) async throws -> [Note] {
        return try await repository.getNotesForStudent(student)
    }
}

