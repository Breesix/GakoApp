//
//  NoteRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftData

class NoteRepositoryImpl: NoteRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func addNote(_ note: Note, for student: Student) async throws {
        student.notes.append(note)
        try context.save()
    }

    func getNotesForStudent(_ student: Student) async throws -> [Note] {
        return student.notes
    }
    
    func updateNote(_ note: Note) async throws {
        try context.save()
    }
}


