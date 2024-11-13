//
//  StudentGridView.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//

import SwiftUI

struct StudentGridView: View {
    let students: [Student]
    @Binding var selectedStudents: Set<Student>
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
                        isSelected: selectedStudents.contains(student),
                        onTap: {
                            if selectedStudents.contains(student) {
                                selectedStudents.remove(student)
                            } else {
                                selectedStudents.insert(student)
                            }
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    StudentGridView(students: [.init(fullname: "Rangga Biner", nickname: "Rangga"), .init(fullname: "Rangga Biner", nickname: "Rangga"), .init(fullname: "John Doe", nickname: "John"), .init(fullname: "Jane Smith", nickname: "Jane")], selectedStudents: .constant([]), onDeleteStudent: { _ in print("Deleted")})
}
