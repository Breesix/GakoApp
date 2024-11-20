//
//  DayEditNewNoteRow.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A row component for adding and editing new student notes
//  Usage: Use this view within DayEditCard to handle new note entries
//

import SwiftUI

struct DayEditNewNoteRow: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DayEditNewNoteRow.titleColor
    private let backgroundColor = UIConstants.DayEditNewNoteRow.backgroundColor
    private let strokeColor = UIConstants.DayEditNewNoteRow.strokeColor
    private let cornerRadius = UIConstants.DayEditNewNoteRow.cornerRadius
    private let strokeWidth = UIConstants.DayEditNewNoteRow.strokeWidth
    private let spacing = UIConstants.DayEditNewNoteRow.spacing
    
    // MARK: - Properties
    let newNote: (id: UUID, note: String)
    @Binding var editedNotes: [UUID: (String, Date)]
    let date: Date
    let onDelete: () -> Void
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: spacing) {
            noteTextField
            deleteButton
        }
    }
    
    // MARK: - Subview
    private var noteTextField: some View {
        TextField("", text: Binding(
            get: { editedNotes[newNote.id]?.0 ?? newNote.note },
            set: { editedNotes[newNote.id] = ($0, date) }
        ))
        .font(.subheadline)
        .fontWeight(.regular)
        .foregroundStyle(titleColor)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(spacing)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(strokeColor, lineWidth: strokeWidth)
        }
    }
    
    // MARK: - Subview
    private var deleteButton: some View {
        DeleteButton(action: onDelete)
    }
}

// MARK: - Preview
#Preview {
    DayEditNewNoteRow(
        newNote: (UUID(), "Sample new note"),
        editedNotes: .constant([:]),
        date: Date(),
        onDelete: {}
    )
    .padding()
}
