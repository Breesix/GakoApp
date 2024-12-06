//
//  DailyEditCard.swift
//  Gako
//
//  Created by Rangga Biner on 11/11/24.
//
//  Description: A card view for editing activities and notes for a specific date.
//  Usage: Use this view to edit activities and notes for a specific date in the daily report section.

import SwiftUI

struct DailyEditCard: View {
    let date: Date
    let activities: [Activity]
    let notes: [Note]
    let student: Student
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    @Binding var editedNotes: [UUID: (String, Date)]
    let onDeleteActivity: (Activity) -> Void
    let onDeleteNote: (Note) -> Void
    let onActivityUpdate: (Activity) -> Void
    let onAddActivity: () -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onEditNote: (Note) -> Void  // Hanya menerima 1 parameter
    let onAddNote: (String) -> Void // Add this new callback

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            EditActivitySection(
                student: student,
                selectedStudent: $selectedStudent,
                isAddingNewActivity: $isAddingNewActivity,
                activities: activities,
                onActivityUpdate: onActivityUpdate,
                onDeleteActivity: onDeleteActivity,
                allActivities: activities,
                allStudents: [student],
                onStatusChanged: { activity, newStatus in
                    Task {
                        await onUpdateActivityStatus(activity, newStatus)
                    }
                },
                onAddActivity: onAddActivity
            )
            .padding(.horizontal, 16)

            Divider()
                .frame(height: 1)
                .background(.tabbarInactiveLabel)
                .padding(.vertical, 4)

            EditNoteSection(
                notes: notes,
                onEditNote: onEditNote,
                onDeleteNote: onDeleteNote,
                onAddNote: {
                    // Create a new empty note
                    onAddNote("")
                }
            )
            .padding(.horizontal, 16)
        }
        .padding(.top, 19)
        .padding(.bottom, 16)
        .background(.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func makeValueBinding(for activity: Activity) -> Binding<String> {
        Binding(
            get: { editedActivities[activity.id]?.0 ?? activity.activity },
            set: { newValue in
                let status = editedActivities[activity.id]?.1 ?? activity.status
                editedActivities[activity.id] = (newValue, status, date)
            }
        )
    }
    
    private func makeStatusBinding(for activity: Activity) -> Binding<Status> {
        Binding(
            get: { editedActivities[activity.id]?.1 ?? activity.status },
            set: { newValue in
                let text = editedActivities[activity.id]?.0 ?? activity.activity
                editedActivities[activity.id] = (text, newValue, date)
            }
        )
    }
}
