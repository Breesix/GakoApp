//
//  ManageNoteView.swift
//  Gako
//
//  Created by Rangga Biner on 04/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A view for managing the addition and editing of student notes
//  Usage: Use this view to create or edit notes for a student, including input validation and alerts
//

import SwiftUI

struct ManageNoteView: View {
    // MARK: - Properties
    @State var noteText: String
    @State var showAlert: Bool = false
    let student: Student
    let selectedDate: Date?
    let onDismiss: () -> Void
    let onSave: (Note) async -> Void
    let onUpdate: (Note) -> Void
    let mode: Mode
    
    // MARK: - Initialization
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
    private let titleColor = UIConstants.ManageNoteView.titleColor
    private let textFieldBackground = UIConstants.ManageNoteView.textFieldBackground
    private let placeholderColor = UIConstants.ManageNoteView.placeholderColor
    private let textColor = UIConstants.ManageNoteView.textColor
    private let borderColor = UIConstants.ManageNoteView.borderColor
    private let spacing = UIConstants.ManageNoteView.spacing
    private let topPadding = UIConstants.ManageNoteView.topPadding
    private let horizontalPadding = UIConstants.ManageNoteView.horizontalPadding
    private let toolbarTopPadding = UIConstants.ManageNoteView.toolbarTopPadding
    private let cornerRadius = UIConstants.ManageNoteView.cornerRadius
    private let borderWidth = UIConstants.ManageNoteView.borderWidth
    private let textEditorHeight = UIConstants.ManageNoteView.textEditorHeight
    private let textEditorHorizontalPadding = UIConstants.ManageNoteView.textEditorHorizontalPadding
    private let placeholderPadding = UIConstants.ManageNoteView.placeholderPadding
    private let addNoteTitle = UIConstants.ManageNoteView.addNoteTitle
    private let editNoteTitle = UIConstants.ManageNoteView.editNoteTitle
    private let placeholderText = UIConstants.ManageNoteView.placeholderText
    private let backButtonText = UIConstants.ManageNoteView.backButtonText
    private let saveButtonText = UIConstants.ManageNoteView.saveButtonText
    private let alertTitle = UIConstants.ManageNoteView.alertTitle
    private let alertMessage = UIConstants.ManageNoteView.alertMessage
    private let okButtonText = UIConstants.ManageNoteView.okButtonText
    private let backIcon = UIConstants.ManageNoteView.backIcon
    
    // MARK: - Body
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
}

// MARK: - Preview
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
