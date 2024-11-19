//
//  MonthlyEditHelper.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

enum MonthlyEditHelper {
    // MARK: - Binding Helpers
    static func makeActivityValueBinding(
        activity: Activity,
        editedActivities: Binding<[UUID: (String, Status, Date)]>,
        date: Date
    ) -> Binding<String> {
        Binding(
            get: { editedActivities.wrappedValue[activity.id]?.0 ?? activity.activity },
            set: { newValue in
                let status = editedActivities.wrappedValue[activity.id]?.1 ?? activity.status
                editedActivities.wrappedValue[activity.id] = (newValue, status, date)
            }
        )
    }
    
    static func makeActivityStatusBinding(
        activity: Activity,
        editedActivities: Binding<[UUID: (String, Status, Date)]>,
        date: Date
    ) -> Binding<Status> {
        Binding(
            get: { editedActivities.wrappedValue[activity.id]?.1 ?? activity.status },
            set: { newValue in
                let text = editedActivities.wrappedValue[activity.id]?.0 ?? activity.activity
                editedActivities.wrappedValue[activity.id] = (text, newValue, date)
            }
        )
    }
    
    static func makeNoteBinding(
        note: Note,
        editedNotes: Binding<[UUID: (String, Date)]>,
        date: Date
    ) -> Binding<String> {
        Binding(
            get: { editedNotes.wrappedValue[note.id]?.0 ?? note.note },
            set: { editedNotes.wrappedValue[note.id] = ($0, date) }
        )
    }
}
