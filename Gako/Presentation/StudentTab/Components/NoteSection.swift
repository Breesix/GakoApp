//
//  NoteSection.swift
//  Gako
//
//  Created by Akmal Hakim on 10/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A section component that displays a list of student notes
//  Usage: Use this view to show a collection of notes with empty state handling
//

import SwiftUI

struct NoteSection: View {
    // MARK: - Constants
    private let titleColor = UIConstants.NoteSection.titleColor
    private let emptyTextColor = UIConstants.NoteSection.emptyTextColor
    private let spacing = UIConstants.NoteSection.sectionSpacing
    private let titleBottomPadding = UIConstants.NoteSection.titleBottomPadding
    private let emptyStateText = UIConstants.NoteSection.emptyStateText
    private let sectionTitle = UIConstants.NoteSection.sectionTitle
    
    // MARK: - Properties
    let notes: [Note]
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let onAddNote: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            title
            if notes.isEmpty {
                emptyState
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
    
    // MARK: - Subview
    private var title: some View {
        Text(sectionTitle)
            .font(.callout)
            .fontWeight(.semibold)
            .foregroundStyle(titleColor)
            .padding(.bottom, titleBottomPadding)
    }

    // MARK: - Subview
    private var emptyState: some View {
        Text(emptyStateText)
            .foregroundColor(emptyTextColor)
    }
}

// MARK: - Preview
#Preview {
    NoteSection(notes: [
        .init(note: "Hari ini rangga sangat baik sekali dalam mengerjakan tugas nya", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
    .padding(.bottom, 200)
    
    // empty state:
    NoteSection(notes: [
    ], onEditNote: { _ in print("edited")}, onDeleteNote: { _ in print("deleted")}, onAddNote: { print("added") })
}
