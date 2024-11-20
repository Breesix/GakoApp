//
//  NoteRow.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct NoteRow: View {
    // MARK: - Constants
    private let textColor = UIConstants.Note.textColor
    private let bulletSpacing = UIConstants.Note.bulletPointSpacing
    private let deleteButtonSize = UIConstants.Note.deleteButtonSize
    private let deleteButtonBackground = UIConstants.Note.deleteButtonBackground
    private let deleteIconColor = UIConstants.Note.deleteIconColor
    
    // MARK: - Properties
    @State private var showDeleteAlert = false
    let note: Note
    let onDelete: (Note) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: bulletSpacing) {
                HStack(alignment: .top, spacing: bulletSpacing) {
                    Text(UIConstants.Note.bulletPoint)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(textColor)

                    Text(note.note)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(textColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#Preview {
    NoteRow(note: .init(note: "rangga sangat hebat sekali dalam mengerjakan tugasnya dia keren banget jksdahbhfjkbsadfjkbhjfabjshfbshjadbfhjbfashjbhjbadshjfbjhabfhjsaf", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onDelete: { _ in print("deleted")})
}
