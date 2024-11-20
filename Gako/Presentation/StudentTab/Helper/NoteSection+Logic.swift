//
//  NoteSection+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import Foundation
import SwiftUI


extension NoteSection {
    // MARK: - Helper Methods
    func isValidNote(_ note: Note) -> Bool {
        return !note.note.isEmpty
    }
    
    func sortedNotes(_ notes: [Note]) -> [Note] {
        return notes.sorted { $0.createdAt > $1.createdAt }
    }
}
