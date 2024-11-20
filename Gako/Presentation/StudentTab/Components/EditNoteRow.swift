//
//  EditNoteRow.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A row component for displaying and editing individual student notes
//  Usage: Use this view to manage a single note entry with editing and deletion capabilities
//

import SwiftUI

struct EditNoteRow: View {
    // MARK: - Constants
    private let rowSpacing = UIConstants.EditNote.rowSpacing
    private let notePadding = UIConstants.EditNote.notePadding
    private let cornerRadius = UIConstants.EditNote.cornerRadius
    private let strokeWidth = UIConstants.EditNote.strokeWidth
    private let deleteButtonSize = UIConstants.EditNote.deleteButtonSize
    private let deleteAlertTitle = UIConstants.EditNote.deleteAlertTitle
    private let deleteAlertMessage = UIConstants.EditNote.deleteAlertMessage
    private let deleteButtonText = UIConstants.EditNote.deleteButtonText
    private let cancelButtonText = UIConstants.EditNote.cancelButtonText
    
    // MARK: - Properties
    @State var showDeleteAlert = false
    @State var showingEditSheet = false
    let note: Note
    let onEdit: (Note) -> Void
    let onDelete: (Note) -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: rowSpacing) {
                noteSection
                deleteButton
            }
        }
        .alert(deleteAlertTitle, isPresented: $showDeleteAlert) {
            Button(cancelButtonText, role: .cancel) { }
            Button(deleteButtonText, role: .destructive) {
                handleDelete()
            }
        } message: {
            Text(deleteAlertMessage)
        }
    }
    
    // MARK: - Subview
    private var noteSection: some View {
        Text(note.note)
            .font(.subheadline)
            .fontWeight(.regular)
            .foregroundStyle(.labelPrimaryBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(notePadding)
            .background(.monochrome100)
            .cornerRadius(cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.noteStroke, lineWidth: strokeWidth)
            }
            .onTapGesture {
                handleEdit()
            }
    }
    
    // MARK: - Subview
    private var deleteButton: some View {
        Button(action: handleDeleteTap) {
            ZStack {
                Circle()
                    .frame(width: deleteButtonSize)
                    .foregroundStyle(.buttonDestructiveOnCard)
                Image(systemName: "trash.fill")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(.destructiveOnCardLabel)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    EditNoteRow(note: .init(note: "rangga sangat hebat sekali dalam mengerjakan tugasnya dia keren banget jksdahbhfjkbsadfjkbhjfabjshfbshjadbfhjbfashjbhjbadshjfbjhabfhjsaf", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onEdit: { _ in print("clicked")}, onDelete: { _ in print("deleted")})
}
