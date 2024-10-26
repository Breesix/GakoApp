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
        VStack(alignment: .leading, spacing: 8) {
            // Profile Header
            ProfileHeaderPreview(student: student)
                .padding(.bottom, 8)
            
            Divider().frame(maxWidth: .infinity)
            
            // Activity Section
            ActivitySectionPreview(
                student: student,
                viewModel: viewModel,
                selectedStudent: $selectedStudent,
                isAddingNewActivity: $isAddingNewActivity
            )
            
            Divider().frame(maxWidth: .infinity)
            
            // Note Section
            NoteSectionPreview(
                student: student,
                viewModel: viewModel,
                selectedStudent: $selectedStudent,
                isAddingNewNote: $isAddingNewNote,
                selectedDate: selectedDate
            )
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
