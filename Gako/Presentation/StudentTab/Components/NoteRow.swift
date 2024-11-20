//
//  NoteRow.swift
//  Gako
//
//  Created by Rangga Biner on 01/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A row component for displaying a single student note with bullet point
//  Usage: Use this view to show individual note entries in a list format
//

import SwiftUI

struct NoteRow: View {
    // MARK: - Constants
    private let textColor = UIConstants.NoteRow.textColor
    private let bulletSpacing = UIConstants.NoteRow.bulletPointSpacing
    private let deleteButtonSize = UIConstants.NoteRow.deleteButtonSize
    private let deleteButtonBackground = UIConstants.NoteRow.deleteButtonBackground
    private let deleteIconColor = UIConstants.NoteRow.deleteIconColor
    
    // MARK: - Properties
    @State private var showDeleteAlert = false
    let note: Note
    let onDelete: (Note) -> Void
    
    // MARK: - Body
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

// MARK: - Preview
#Preview {
    NoteRow(note: .init(note: "rangga sangat hebat sekali dalam mengerjakan tugasnya dia keren banget jksdahbhfjkbsadfjkbhjfabjshfbshjadbfhjbfashjbhjbadshjfbjhabfhjsaf", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onDelete: { _ in print("deleted")})
}
