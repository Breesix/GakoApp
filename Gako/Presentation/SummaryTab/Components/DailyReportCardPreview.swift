//
//  DailyReportCardPreview.swift
//  Gako
//
//  Created by Kevin Fairuz on 26/10/24.
//
//  Description: A preview view for the daily report card, displaying student activities and notes.
//  Usage: Use this view to show a preview of the daily report card for a student.

import SwiftUI

struct DailyReportCardPreview: View {
    let student: Student
    let selectedDate: Date
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    @Binding var isAddingNewNote: Bool
    @State private var isEditing = false
    let hasDefaultActivities: Bool
    
    let onUpdateActivity: (UnsavedActivity) -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void
    let onUpdateNote: (UnsavedNote) -> Void
    let onDeleteNote: (UnsavedNote) -> Void
    let activities: [UnsavedActivity]
    let notes: [UnsavedNote]
    let allActivities: [UnsavedActivity]
    let allStudents: [Student]
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ProfileHeaderPreview(student: student, hasDefaultActivities: hasDefaultActivities)
                    .padding(12)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .overlay(.graysGray3)
                
                VStack(alignment: .leading, spacing: 0) {
                    ActivitySectionPreview(
                        student: student,
                        selectedStudent: $selectedStudent,
                        isAddingNewActivity: $isAddingNewActivity,
                        activities: activities,
                        onActivityUpdate: onUpdateActivity,
                        onDeleteActivity: onDeleteActivity,
                        allActivities: allActivities,
                        allStudents: allStudents
                    )
                    
                    Divider()
                        .padding(.vertical, 16)
                        .frame(height: 1)
                        .overlay(.tabbarInactiveLabel)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    
                    NoteSectionPreview(
                        student: student,
                        notes: notes,
                        selectedStudent: $selectedStudent,
                        isAddingNewNote: $isAddingNewNote,
                        selectedDate: selectedDate,
                        onUpdateNote: onUpdateNote,
                        onDeleteNote: onDeleteNote
                    )
                }
                .padding(16)
            }
            .background(.white)
            .cornerRadius(10)
        }
    }
}
