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
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Text(mode == .add ? "Tambah Catatan" : "Edit Catatan")
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
                    Text(mode == .add ? "Tambah Catatan" : "Edit Catatan")
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
                            saveNote()
                        }
                    }) {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.medium)
                    }
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
