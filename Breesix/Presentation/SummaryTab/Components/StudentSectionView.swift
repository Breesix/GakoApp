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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ProfileHeaderPreview(student: student)
                .padding(12)
                
            Divider()
            
            VStack (alignment: .leading, spacing: 0) {
                ActivitySectionPreview(
                    student: student,
                    viewModel: viewModel,
                    selectedStudent: $selectedStudent,
                    isAddingNewActivity: $isAddingNewActivity
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
