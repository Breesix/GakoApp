//
//  ActivitySectionPreview.swift
//  Gako
//
//  Created by Kevin Fairuz on 26/10/24.
//
//  Description: A preview section for displaying student activities.
//  Usage: Use this view to show a list of activities for a specific student.

import SwiftUI
import Mixpanel

struct ActivitySectionPreview: View {
    let student: Student
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    
    let activities: [UnsavedActivity]
    @State private var editingActivity: UnsavedActivity?
    
    let onActivityUpdate: (UnsavedActivity) -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void
    
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    let allActivities: [UnsavedActivity]
    let allStudents: [Student]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("AKTIVITAS")
                .foregroundStyle(.labelPrimaryBlack)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.bottom, 16)
            
            let studentActivities = activities.filter { $0.studentId == student.id }
            
            if !studentActivities.isEmpty {
                ForEach(Array(studentActivities.enumerated()), id: \.element.id) { index, activity in
                    ActivityRowPreview(
                        activity: binding(for: activity),
                        activityIndex: index,
                        student: student,
                        onAddActivity: {
                            isAddingNewActivity = true
                        },
                        onEdit: { activity in
                            editingActivity = activity
                        },
                        onDelete: {
                            onDeleteActivity(activity)
                        },
                        onDeleteActivity: { activity in
                            onDeleteActivity(activity)
                        }
                    )
                    .padding(.bottom, 16)
                }
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondaryBlack)
                    .padding(.bottom, 12)
            }
            
            AddItemButton(
                onTapAction: {
                    selectedStudent = student
                    isAddingNewActivity = true
                },
                bgColor: .buttonOncard, text: "Tambah"
            )
        }
        .sheet(item: $editingActivity) { activity in
            ManageUnsavedActivityView(
                mode: .edit(activity),
                allActivities: allActivities,
                allStudents: allStudents,
                onSave: { updatedActivity in
                    onActivityUpdate(updatedActivity)
                    editingActivity = nil
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
    }
}
