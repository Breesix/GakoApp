//
//  NoteRow.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct NoteRow: View {
    @State private var showDeleteAlert = false
    let note: Note
    
    let onDelete: (Note) -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 0) {
            HStack (alignment: .top, spacing: 8) {
                Text("•")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(.labelPrimaryBlack)

                Text(note.note)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(.labelPrimaryBlack)
                
            }
        }
    }
}

#Preview {
    NoteRow(note: .init(note: "rangga sangat hebat sekali dalam mengerjakan tugasnya dia keren banget jksdahbhfjkbsadfjkbhjfabjshfbshjadbfhjbfashjbhjbadshjfbjhabfhjsaf", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onDelete: { _ in print("deleted")})
}
