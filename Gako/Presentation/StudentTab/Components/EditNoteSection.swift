//
//  EditNoteSection.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI

struct EditNoteSection: View {
    // MARK: - Constants
    private let sectionTitle = UIConstants.EditNote.sectionTitle
    private let emptyStateText = UIConstants.EditNote.emptyStateText
    private let addButtonText = UIConstants.EditNote.addButtonText
    private let sectionSpacing = UIConstants.EditNote.sectionSpacing
    private let titleBottomPadding = UIConstants.EditNote.titleBottomPadding
    
    // MARK: - Properties
    let notes: [Note]
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let onAddNote: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            Text(sectionTitle)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .padding(.bottom, titleBottomPadding)

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
}

#Preview {
    EditNoteSection(notes: [
        .init(note: "Hari ini rangga sangat baik sekali dalam mengerjakan tugas nya", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
    .padding(.bottom, 200)
    
    // empty state:
    NoteSection(notes: [
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
}
