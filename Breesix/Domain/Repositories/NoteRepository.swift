//
//  NoteRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

protocol NoteRepository {
    func addNote(_ note: Note, for student: Student) async throws
    func getNotesForStudent(_ student: Student) async throws -> [Note]
    func updateNote(_ note: Note) async throws
}
