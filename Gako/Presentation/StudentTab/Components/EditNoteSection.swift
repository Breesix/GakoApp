//
//  EditNoteSection.swift
//  Gako
//
//  Created by Rangga Biner on 10/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A section component that manages a collection of student notes
//  Usage: Use this view to display and manage multiple note entries for a student
//

import SwiftUI

struct EditNoteSection: View {
    // MARK: - Constants
    private let sectionTitle = UIConstants.EditNoteSection.sectionTitle
    private let emptyStateText = UIConstants.EditNoteSection.emptyStateText
    private let addButtonText = UIConstants.EditNoteSection.addButtonText
    private let sectionSpacing = UIConstants.EditNoteSection.sectionSpacing
    private let titleBottomPadding = UIConstants.EditNoteSection.titleBottomPadding
    
    // MARK: - Properties
    let notes: [Note]
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let onAddNote: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            title
            if notes.isEmpty {
                Text(emptyStateText)
                    .foregroundColor(.secondary)
            } else {
                ForEach(notes, id: \.id) { note in
                    EditNoteRow(
                        note: note,
                        onEdit: onEditNote,
                        onDelete: onDeleteNote
                    )
                }
            }
            AddItemButton(
                onTapAction: onAddNote,
                bgColor: .buttonOncard,
                text: addButtonText
            )
        }
    }
    
    // MARK: - Subview
    private var title: some View {
        Text(sectionTitle)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(.labelPrimaryBlack)
            .padding(.bottom, titleBottomPadding)

    }
}

// MARK: - Preview
#Preview {
    EditNoteSection(notes: [
        .init(note: "Hari ini rangga sangat baik sekali dalam mengerjakan tugas nya", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
    .padding(.bottom, 200)
    
    // empty state:
    NoteSection(notes: [
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
}
