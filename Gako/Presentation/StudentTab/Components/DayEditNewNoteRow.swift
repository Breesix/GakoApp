//
//  DayEditNewNoteRow.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct DayEditNewNoteRow: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DayEdit.titleColor
    private let backgroundColor = UIConstants.Edit.backgroundColor
    private let strokeColor = UIConstants.Edit.strokeColor
    private let cornerRadius = UIConstants.Edit.cornerRadius
    private let strokeWidth = UIConstants.Edit.strokeWidth
    private let spacing = UIConstants.DayEdit.spacing
    
    // MARK: - Properties
    let newNote: (id: UUID, note: String)
    @Binding var editedNotes: [UUID: (String, Date)]
    let date: Date
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: spacing) {
            noteTextField
            deleteButton
        }
    }
    
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
    
    private var deleteButton: some View {
        DeleteButton(action: onDelete)
    }
}
