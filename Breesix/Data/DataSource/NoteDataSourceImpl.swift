//
//  NoteDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation
import SwiftData

class NoteDataSourceImpl: NoteDataSource {
    private let modelContext: ModelContext
    
    init(context: ModelContext) {
        self.modelContext = context
    }
    
    func fetchAllNotes(_ student: Student) async throws -> [Note] {
        return student.notes
    }
    
    func insert(_ note: Note, for student: Student) async throws {
        student.notes.append(note)
        try modelContext.save()
    }
    
    func update(_ note: Note) async throws {
        try modelContext.save()
    }
    
    func delete(_ note: Note, from student: Student) async throws {
        student.notes.removeAll { $0.id == note.id }
        modelContext.delete(note)
        try modelContext.save()
    }
}
