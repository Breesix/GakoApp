//
//  StudentSectionView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct StudentSectionView: View {
    let student: Student
    let viewModel: StudentTabViewModel
    let selectedDate: Date
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    @Binding var isAddingNewNote: Bool
    let onDeleteActivity: (UnsavedActivity) -> Void
    @State private var isEditing = false
    
    var body: some View {
        ZStack {
            
            VStack(alignment: .leading, spacing: 0) {
                ProfileHeaderPreview(student: student)
                    .padding(12)
                
                Divider()
                
                VStack (alignment: .leading, spacing: 0) {
                    ActivitySectionPreview(
                        student: student,
                        viewModel: viewModel,
                        selectedStudent: $selectedStudent,
                        isAddingNewActivity: $isAddingNewActivity,
                        onDeleteActivity: { activity in
                            viewModel.deleteUnsavedActivity(activity)
                        }
                    )
                    
                    Divider()
                        .padding(.vertical, 16)
                    
                    NoteSectionPreview(
                        student: student,
                        viewModel: viewModel,
                        selectedStudent: $selectedStudent,
                        isAddingNewNote: $isAddingNewNote,
                        selectedDate: selectedDate
                    )
                    
                }
                .padding(16)
            }
            .background(.white)
            .cornerRadius(10)
        }

    }
        
}
