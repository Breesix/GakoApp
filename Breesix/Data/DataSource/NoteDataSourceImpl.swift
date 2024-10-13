//
//  NoteDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation
import SwiftData

class NoteDataSourceImpl: NoteDataSource {
    private let modelContext: ModelContext

    init(context: ModelContext) {
        self.modelContext = context
    }

    func fetch() async throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        let notes = try modelContext.fetch(descriptor)
        return notes
    }

    func insert(_ note: Note) async throws {
        modelContext.insert(note)
        try modelContext.save()
    }

    func update(_ note: Note) async throws {
        try modelContext.save()
    }

    func delete(_ note: Note) async throws {
        modelContext.delete(note)
        try modelContext.save()
    }
}
