//
//  NoteRow+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import Foundation


extension NoteRow {
    // MARK: - Delete Handling
    func handleDelete() {
        onDelete(note)
    }
    
    // MARK: - Validation
    func validateNote() -> Bool {
        return !note.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Text Processing
    func truncatedNote(maxLength: Int = 100) -> String {
        if note.note.count > maxLength {
            return String(note.note.prefix(maxLength)) + "..."
        }
        return note.note
    }
    
    func formattedNote() -> String {
        return note.note.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
