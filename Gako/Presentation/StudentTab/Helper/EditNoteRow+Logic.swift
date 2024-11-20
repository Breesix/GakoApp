//
//  EditActivityRow+Logic.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides logic operations for EditNoteRow
//  Usage: Contains methods for handling actions, validation, and formatting of notes
//

import Foundation

extension EditNoteRow {
    // MARK: - Action Handlers
    func handleEdit() {
        onEdit(note)
        showingEditSheet = true
    }
    
    func handleDeleteTap() {
        showDeleteAlert = true
    }
    
    func handleDelete() {
        onDelete(note)
    }
    
    // MARK: - Validation
    func isValidNote() -> Bool {
        return !note.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func canEdit() -> Bool {
        return isValidNote()
    }
    
    // MARK: - Formatting
    func formattedNote() -> String {
        return note.note.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
