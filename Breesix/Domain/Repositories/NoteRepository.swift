//
//  NoteRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

protocol NoteRepository {
    func addNote(_ note: Activity, for student: Student) async throws
    func getNotesForStudent(_ student: Student) async throws -> [Activity]
    func updateNote(_ note: Activity) async throws
    func deleteNote(_ note: Activity, from student: Student) async throws
}
