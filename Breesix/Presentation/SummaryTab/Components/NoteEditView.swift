//
//  NoteEditView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 28/10/24.
//


import SwiftUI

struct NoteEditPreview: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @Environment(\.dismiss) var dismiss
    let note: UnsavedNote
    let onDismiss: () -> Void
    @State private var noteText: String
    let onSave: (UnsavedNote) -> Void
    
    init(viewModel: StudentTabViewModel, note: UnsavedNote, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.note = note
        self.onDismiss = onDismiss
        _noteText = State(initialValue: note.note)
    }

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Edit Catatan")
                    .font(.callout)
                    .fontWeight(.semibold)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.cardFieldBG)
                        .frame(maxWidth: .infinity, maxHeight: 170)
                    
                    if noteText.isEmpty {
                        Text("Tuliskan catatan untuk murid...")
                            .font(.callout)
                            .fontWeight(.regular)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity, maxHeight: 170, alignment: .topLeading)
                            .foregroundColor(.labelDisabled)
                            .cornerRadius(8)
                    }
                    
                    TextEditor(text: $noteText)
                        .font(.callout)
                        .fontWeight(.regular)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, maxHeight: 170)
                        .cornerRadius(8)
                        .scrollContentBackground(.hidden)
                }
                .onAppear() {
                    UITextView.appearance().backgroundColor = .clear
                }
                .onDisappear() {
                    UITextView.appearance().backgroundColor = nil
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.monochrome50, lineWidth: 1)
                )
                
                Spacer()
            }
            .padding(.top, 34.5)
            .padding(.horizontal, 16)
            .navigationTitle("Edit Catatan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Catatan")
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        onDismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Kembali")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Simpan") {
                        let updatedNote = UnsavedNote(
                            id: note.id,
                            note: noteText,
                            createdAt: note.createdAt,
                            studentId: note.studentId
                        )
                        onSave(updatedNote)
                        dismiss()
                    }
                    .disabled(noteText.isEmpty)
                }
            }
        }
    }



