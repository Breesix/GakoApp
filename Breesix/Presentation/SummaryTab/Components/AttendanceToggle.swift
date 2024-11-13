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
    @Binding var selectedStudents: Set<Student>
    
    var body: some View {
        Toggle("Semua murid hadir hari ini", isOn: $isToggleOn)
            .font(.callout)
            .fontWeight(.semibold)
            .tint(.bgAccent)
            .onChange(of: isToggleOn) {
                if isToggleOn {
                    selectedStudents = Set(students)
                } else {
                    selectedStudents.removeAll()
                }
            }
    }
}


#Preview {
    AttendanceToggle(isToggleOn: .constant(true), students: [.init(fullname: "Rangga Biner", nickname: "Rangga")], selectedStudents: .constant([]))
}
