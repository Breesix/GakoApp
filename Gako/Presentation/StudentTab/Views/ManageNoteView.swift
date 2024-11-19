//
//  ManageNoteView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.
//

import SwiftUI

struct ManageNoteView: View {
    
    @State private var noteText: String
    @State private var showAlert: Bool = false
    
    let student: Student
    let selectedDate: Date?
    let onDismiss: () -> Void
    let onSave: (Note) async -> Void
    let onUpdate: (Note) -> Void
    
    enum Mode: Equatable {
        case add
        case edit(Note)
        
        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.add, .add):
                return true
            case let (.edit(note1), .edit(note2)):
                return note1.id == note2.id
            default:
                return false
            }
        }
    }
    
    let mode: Mode
    
    init(mode: Mode,
         student: Student,
         selectedDate: Date? = nil,
         onDismiss: @escaping () -> Void,
         onSave: @escaping (Note) async -> Void,
         onUpdate: @escaping (Note) -> Void) {
        self.mode = mode
        self.student = student
        self.selectedDate = selectedDate
        self.onDismiss = onDismiss
        self.onSave = onSave
        self.onUpdate = onUpdate
        
        switch mode {
        case .add:
            _noteText = State(initialValue: "")
        case .edit(let note):
            _noteText = State(initialValue: note.note)
        }
    }
    
    // MARK: - Constants
    private let titleColor = UIConstants.ManageNote.titleColor
    private let textFieldBackground = UIConstants.ManageNote.textFieldBackground
    private let placeholderColor = UIConstants.ManageNote.placeholderColor
    private let textColor = UIConstants.ManageNote.textColor
    private let borderColor = UIConstants.ManageNote.borderColor
    
    private let spacing = UIConstants.ManageNote.spacing
    private let topPadding = UIConstants.ManageNote.topPadding
    private let horizontalPadding = UIConstants.ManageNote.horizontalPadding
    private let toolbarTopPadding = UIConstants.ManageNote.toolbarTopPadding
    private let cornerRadius = UIConstants.ManageNote.cornerRadius
    private let borderWidth = UIConstants.ManageNote.borderWidth
    private let textEditorHeight = UIConstants.ManageNote.textEditorHeight
    private let textEditorHorizontalPadding = UIConstants.ManageNote.textEditorHorizontalPadding
    private let placeholderPadding = UIConstants.ManageNote.placeholderPadding
    
    private let addNoteTitle = UIConstants.ManageNote.addNoteTitle
    private let editNoteTitle = UIConstants.ManageNote.editNoteTitle
    private let placeholderText = UIConstants.ManageNote.placeholderText
    private let backButtonText = UIConstants.ManageNote.backButtonText
    private let saveButtonText = UIConstants.ManageNote.saveButtonText
    private let alertTitle = UIConstants.ManageNote.alertTitle
    private let alertMessage = UIConstants.ManageNote.alertMessage
    private let okButtonText = UIConstants.ManageNote.okButtonText
    private let backIcon = UIConstants.ManageNote.backIcon
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: spacing) {
                Text(mode == .add ? addNoteTitle : editNoteTitle)
                    .foregroundStyle(titleColor)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(textFieldBackground)
                        .frame(maxWidth: .infinity, maxHeight: textEditorHeight)
                    
                    if noteText.isEmpty {
                        Text(placeholderText)
                            .font(.callout)
                            .fontWeight(.regular)
                            .padding(placeholderPadding)
                            .frame(maxWidth: .infinity, maxHeight: textEditorHeight, alignment: .topLeading)
                            .foregroundColor(placeholderColor)
                            .cornerRadius(cornerRadius)                    }
                    
                    TextEditor(text: $noteText)
                        .foregroundStyle(textColor)
                        .font(.callout)
                        .fontWeight(.regular)
                        .padding(.horizontal, textEditorHorizontalPadding)
                        .frame(maxWidth: .infinity, maxHeight: textEditorHeight)
                        .cornerRadius(cornerRadius)
                        .scrollContentBackground(.hidden)
                }
                .onAppear() {
                    UITextView.appearance().backgroundColor = .clear
                }
                .onDisappear() {
                    UITextView.appearance().backgroundColor = nil
                }
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                
                Spacer()
            }
            .padding(.top, topPadding)
                       .padding(.horizontal, horizontalPadding)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(mode == .add ? addNoteTitle : editNoteTitle)
                        .foregroundStyle(titleColor)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, toolbarTopPadding)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        onDismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: backIcon)
                                .fontWeight(.semibold)
                            Text(backButtonText)
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.top, toolbarTopPadding)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showAlert = true
                        } else {
                            saveNote()
                        }
                    }) {
                        Text(saveButtonText)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.top, toolbarTopPadding)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button(okButtonText, role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveNote() {
        switch mode {
        case .add:
            guard let date = selectedDate else { return }
            let newNote = Note(note: noteText, createdAt: date, student: student)
            Task {
                await onSave(newNote)
                onDismiss()
            }
        case .edit(let note):
            note.note = noteText
            onUpdate(note)
            onDismiss()
        }
    }
}

#Preview {
    ManageNoteView(
        mode: .add,
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        selectedDate: .now,
        onDismiss: { print("dismissed") },
        onSave: { _ in print("saved") },
        onUpdate: { _ in print("updated") }
    )
}
