//
//  AttendanceToggle.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//

import SwiftUI

struct AttendanceToggle: View {
    @Binding var isToggleOn: Bool
    let students: [Student]
    @EnvironmentObject var studentViewModel: StudentViewModel
    
    var body: some View {
        Toggle("Semua murid hadir hari ini", isOn: Binding(
            get: {
                // Check if all students are selected
                !students.isEmpty && studentViewModel.selectedStudents.count == students.count
            },
            set: { newValue in
                if newValue {
                    // Select all students
                    studentViewModel.selectedStudents = Set(students)
                } else {
                    // Unselect all students
                    studentViewModel.selectedStudents.removeAll()
                }
            }
        ))
        .font(.callout)
        .fontWeight(.semibold)
        .tint(.bgAccent)
    }
}


//#Preview {
//    AttendanceToggle(isToggleOn: .constant(true), selectedStudents: .constant([]))
//}
