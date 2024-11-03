//
//  EditNote.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

struct EditNote: View {
    @State private var noteText: String
    let note: Note
    
    let onDismiss: () -> Void
    let onSave: (Note) -> Void

    init(note: Note,
         onDismiss: @escaping () -> Void,
         onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onDismiss = onDismiss
        self.onSave = onSave
        _noteText = State(initialValue: note.note)
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Edit Catatan")
                    .foregroundStyle(.labelPrimaryBlack)
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
                        .foregroundStyle(.labelPrimaryBlack)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Catatan")
                        .foregroundStyle(.labelPrimaryBlack)
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
                    Button(action: {
                        saveNote()
                    }, label: {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.medium)
                    })
                    .padding(.top, 27)
                }
            }
        }
    }

    private func saveNote() {
        let updatedNote = note
        updatedNote.note = noteText
        onSave(updatedNote)
        onDismiss()
    }
}

#Preview {
    EditNote(note: .init(note: "Anak ini pintar sekali", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onDismiss: { print("dismissed")}, onSave: { _ in print("saved")})
}


