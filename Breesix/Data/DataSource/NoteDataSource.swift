//
//  NoteDataSource.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation

protocol NoteDataSource {
    func fetch() async throws -> [Note]
    func insert(_ note: Note) async throws
    func update(_ note: Note) async throws
    func delete(_ note: Note) async throws
}
