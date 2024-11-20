//
//  DayEditNoteRow.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A row component for editing existing student notes
//  Usage: Use this view within DayEditCard to manage existing note entries
//

import SwiftUI

struct DayEditNoteRow: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DayEdit.titleColor
    private let backgroundColor = UIConstants.DayEditNoteRow.backgroundColor
    private let strokeColor = UIConstants.DayEditNoteRow.strokeColor
    private let cornerRadius = UIConstants.DayEditNoteRow.cornerRadius
    private let strokeWidth = UIConstants.DayEditNoteRow.strokeWidth
    private let spacing = UIConstants.DayEditNoteRow.spacing
    
    // MARK: - Properties
    let note: Note
    @Binding var editedNotes: [UUID: (String, Date)]
    let date: Date
    let onDelete: (Note) -> Void
    @State private var showDeleteAlert = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack {
                noteTextField
                deleteButton
            }
        }
        .alert(UIConstants.Edit.deleteAlertTitle, isPresented: $showDeleteAlert) {
            Button(UIConstants.Edit.cancelButtonText, role: .cancel) { }
            Button(UIConstants.Edit.deleteButtonText, role: .destructive) {
                onDelete(note)
            }
        } message: {
            Text(UIConstants.Edit.deleteAlertMessage)
        }
    }
    
    // MARK: - Subview
    private var noteTextField: some View {
        TextField("", text: EditBindingHelper.makeNoteBinding(
            note: note,
            editedNotes: $editedNotes,
            date: date
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
        DeleteButton(action: { showDeleteAlert = true })
    }
}

// MARK: - Preview
#Preview {
    DayEditNoteRow(note: .init(note: "Semua anak keren", student: .init(fullname: "Rangga", nickname: "Hadi")), editedNotes: .constant([:]), date: Date(), onDelete: { _ in })
}
