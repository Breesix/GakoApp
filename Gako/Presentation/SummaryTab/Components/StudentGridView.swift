//
//  StudentGridView.swift
//  Gako
//
//  Created by Rangga Biner on 13/11/24.
//
//  Description: A view that displays a grid of students in the progressCurhat view.
//  Usage: Use this view to display a grid of students in the progressCurhat view.      

import SwiftUI

struct StudentGridView: View {
    let students: [Student]
    @EnvironmentObject var studentViewModel: StudentViewModel
    var onDeleteStudent: (Student) async -> Void
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(students) { student in
                    CheckStudentCard(
                        student: student,
                        onDelete: {
                            Task {
                                await onDeleteStudent(student)
                            }
                        },
                        isSelected: studentViewModel.selectedStudents.contains(student),
                        onTap: {
                            if studentViewModel.selectedStudents.contains(student) {
                                studentViewModel.selectedStudents.remove(student)
                            } else {
                                studentViewModel.selectedStudents.insert(student)
                            }
                        }
                    )
                }
            }
        }
    }
}
//
//#Preview {
//    StudentGridView(students: [.init(fullname: "Rangga Biner", nickname: "Rangga"), .init(fullname: "Rangga Biner", nickname: "Rangga"), .init(fullname: "John Doe", nickname: "John"), .init(fullname: "Jane Smith", nickname: "Jane")], selectedStudents: .constant([]), onDeleteStudent: { _ in print("Deleted")})
//}
