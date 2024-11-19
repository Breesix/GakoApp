//
//  EditSection+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import Foundation

extension EditNoteSection {
    // MARK: - Validation
    func hasNotes() -> Bool {
        return !notes.isEmpty
    }
    
    func isValidNote(_ note: Note) -> Bool {
        return !note.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Sorting
    func sortedNotes() -> [Note] {
        return notes.sorted { $0.createdAt > $1.createdAt }
    }
}
