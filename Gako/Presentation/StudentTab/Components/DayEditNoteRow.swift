//
//  DayEditNoteRow.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI 

struct DayEditNoteRow: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DayEdit.titleColor
    private let backgroundColor = UIConstants.Edit.backgroundColor
    private let strokeColor = UIConstants.Edit.strokeColor
    private let cornerRadius = UIConstants.Edit.cornerRadius
    private let strokeWidth = UIConstants.Edit.strokeWidth
    private let spacing = UIConstants.DayEdit.spacing
    
    // MARK: - Properties
    let note: Note
    @Binding var editedNotes: [UUID: (String, Date)]
    let date: Date
    let onDelete: (Note) -> Void
    @State private var showDeleteAlert = false
    
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
    
    private var deleteButton: some View {
        DeleteButton(action: { showDeleteAlert = true })
    }
}
