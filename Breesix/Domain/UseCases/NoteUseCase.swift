//
//  NoteUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

struct notesUseCase {
    let repository: NoteRepository

    func addNote(_ note: Activity, for student: Student) async throws {
        try await repository.addNote(note, for: student)
    }

    func getNotesForStudent(_ student: Student) async throws -> [Activity] {
        return try await repository.getNotesForStudent(student)
    }
    
    func updateNote(_ note: Activity) async throws {
        try await repository.updateNote(note)
    }
    
    func deleteNote(_ note: Activity, from student: Student) async throws {
        try await repository.deleteNote(note, from: student)
    }

}

