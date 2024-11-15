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
        Toggle("Semua murid hadir hari ini", isOn: $isToggleOn)
            .font(.callout)
            .fontWeight(.semibold)
            .tint(.bgAccent)
            .onChange(of: isToggleOn) {
                if isToggleOn {
                    studentViewModel.selectedStudents = Set(students)
                } else {
                    studentViewModel.selectedStudents.removeAll()
                }
            }
    }
}


//#Preview {
//    AttendanceToggle(isToggleOn: .constant(true), selectedStudents: .constant([]))
//}
