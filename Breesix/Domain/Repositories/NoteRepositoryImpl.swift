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

    func addNote(_ note: Activity, for student: Student) async throws {
        student.notes.append(note)
        try context.save()
    }

    func getNotesForStudent(_ student: Student) async throws -> [Activity] {
        return student.notes
    }
    
    func updateNote(_ note: Activity) async throws {
        try context.save()
    }
    
    func deleteNote(_ note: Activity, from student: Student) async throws {
        student.notes.removeAll { $0.id == note.id }
        context.delete(note)
        try context.save()
    }

}


