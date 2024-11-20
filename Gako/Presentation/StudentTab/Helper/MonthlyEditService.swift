//
//  MonthlyEditService.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: An actor service that handles monthly editing operations
//  Usage: Use this service to manage activity and note updates in monthly view
//

import SwiftUI

actor MonthlyEditService {
    // MARK: - Activity Operations
    func updateActivityStatus(
        activity: Activity,
        newStatus: Status,
        onUpdateActivityStatus: @escaping (Activity, Status) async -> Void
    ) async {
        await onUpdateActivityStatus(activity, newStatus)
    }
    
    func handleActivityUpdate(
        activity: Activity,
        editedActivities: inout [UUID: (String, Status, Date)],
        date: Date,
        onActivityUpdate: (Activity) -> Void
    ) {
        if let editedActivity = editedActivities[activity.id] {
            let updatedActivity = activity
            updatedActivity.activity = editedActivity.0
            updatedActivity.status = editedActivity.1
            onActivityUpdate(updatedActivity)
        }
    }
    
    // MARK: - Note Operations
    func handleNoteAddition(
        note: String,
        date: Date,
        editedNotes: inout [UUID: (String, Date)],
        onAddNote: (String) -> Void
    ) {
        onAddNote(note)
    }
    
    func handleNoteEdit(
        note: Note,
        editedNotes: [UUID: (String, Date)],
        onEditNote: (Note) -> Void
    ) {
        if let editedNote = editedNotes[note.id] {
            var updatedNote = note
            updatedNote.note = editedNote.0
            onEditNote(updatedNote)
        }
    }
}
