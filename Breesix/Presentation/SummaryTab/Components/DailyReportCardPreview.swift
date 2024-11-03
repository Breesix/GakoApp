//
//  DailyReportCardPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
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
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                ProfileHeaderPreview(student: student, hasDefaultActivities: hasDefaultActivities)
                    .padding(12)
                
                Divider()
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 0) {
                    ActivitySectionPreview(
                        student: student,
                        selectedStudent: $selectedStudent,
                        isAddingNewActivity: $isAddingNewActivity,
                        activities: activities,
                        onActivityUpdate: onUpdateActivity,
                        onDeleteActivity: onDeleteActivity
                    )
                    
                    Divider()
                        .padding(.vertical, 16)
                    
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

#Preview {
    DailyReportCardPreview(
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        selectedDate: Date(),
        selectedStudent: .constant(nil),
        isAddingNewActivity: .constant(false),
        isAddingNewNote: .constant(false),
        hasDefaultActivities: true,
        onUpdateActivity: { _ in },
        onDeleteActivity: { _ in },
        onUpdateNote: { _ in },
        onDeleteNote: { _ in },
        activities: [
            .init(activity: "Menjahit", createdAt: .now, studentId: UUID())
        ],
        notes: [
            .init(note: "Anak ini baiikkkkk sekali", createdAt: .now, studentId: UUID())
        ]
    )
    .padding(20)
    .background(.gray)
}
