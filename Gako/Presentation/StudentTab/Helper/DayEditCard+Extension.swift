//
//  DayEditCard+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension for DayEditCard that provides additional functionality for managing activities and notes
//  Usage: Implement these methods to handle adding and removing activities and notes
//

import Foundation

extension DayEditCard {
    // MARK: - Add Activity
    func addNewActivity() {
        let newId = UUID()
        newActivities.append((id: newId, activity: "", status: .tidakMelakukan))
        editedActivities[newId] = ("", .tidakMelakukan, date)
    }

    // MARK: - Remove Activity
    func removeNewActivity(id: UUID) {
        newActivities.removeAll(where: { $0.id == id })
        editedActivities.removeValue(forKey: id)
    }
    
    // MARK: - Add Note
    func addNewNote() {
        let newId = UUID()
        newNotes.append((id: newId, note: ""))
        editedNotes[newId] = ("", date)
    }
    
    // MARK: - Remove Note
    func removeNewNote(id: UUID) {
        newNotes.removeAll(where: { $0.id == id })
        editedNotes.removeValue(forKey: id)
    }
    
}
