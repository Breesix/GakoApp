//
//  NoteSection.swift
//  Breesix
//
//  Created by Akmal Hakim on 10/10/24.
//

import SwiftUI

struct NoteSection: View {
    // MARK: - Constants
    private let titleColor = UIConstants.Note.titleColor
    private let emptyTextColor = UIConstants.Note.emptyTextColor
    private let spacing = UIConstants.Note.sectionSpacing
    private let titleBottomPadding = UIConstants.Note.titleBottomPadding
    
    // MARK: - Properties
    let notes: [Note]
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let onAddNote: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(UIConstants.Note.sectionTitle)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(titleColor)
                .padding(.bottom, titleBottomPadding)

            if notes.isEmpty {
                Text(UIConstants.Note.emptyStateText)
                    .foregroundColor(emptyTextColor)
            } else {
                ForEach(Array(notes.enumerated()), id: \.element.id) { index, note in
                    NoteRow(
                        note: note,
                        onDelete: onDeleteNote
                    )
                }
            }
        }
    }
}

#Preview {
    NoteSection(notes: [
        .init(note: "Hari ini rangga sangat baik sekali dalam mengerjakan tugas nya", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
    .padding(.bottom, 200)
    
    // empty state:
    NoteSection(notes: [
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
}
