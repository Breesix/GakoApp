//
//  NewNote.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.
//

import SwiftUI

struct AddNote: View {
    @State private var noteText: String = ""
    @State private var showAlert: Bool = false
    let student: Student
    let selectedDate: Date
    
    let onDismiss: () -> Void
    let onSave: (Note) async -> Void

    var body: some View {
        NavigationView {
            VStack (alignment: .leading, spacing: 8){
                Text("Tambah Catatan")
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
                    Text("Tambah Catatan")
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
                        if noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showAlert = true 
                        } else {
                            saveNewNote()
                        }
                    }, label: {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.medium)
                    })
                    .padding(.top, 27)
                }
            }
            .alert("Peringatan", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Catatan tidak boleh kosong")
            }
        }
    }

    private func saveNewNote() {
        let newNote = Note(note: noteText, createdAt: selectedDate, student: student)
        Task {
            await onSave(newNote)
            onDismiss()
        }
    }
}

#Preview {
    AddNote(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), selectedDate: .now, onDismiss: { print("dismissed")}, onSave: { _ in
        print("saved")
    }
    )
}
