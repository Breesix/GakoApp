//
//  NoteRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 02/10/24.
//

import Foundation
import SwiftData

class NoteRepositoryImpl: NoteRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAllNotes(_ student: Student) async throws -> [Note] {
        return student.notes
    }

    func addNote(_ note: Note, for student: Student) async throws {
        student.notes.append(note)
        try context.save()
    }

    func updateNote(_ note: Note) async throws {
        try context.save()
    }

    func deleteNote(_ note: Note, from student: Student) async throws {
        student.notes.removeAll { $0.id == note.id }
        context.delete(note)
        try context.save()
    }
}
