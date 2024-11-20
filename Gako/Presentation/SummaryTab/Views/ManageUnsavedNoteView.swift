//
//  ManageUnsavedNoteView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import SwiftUI
import Mixpanel

struct ManageUnsavedNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var textNote: String
    @State private var showAlert: Bool = false
    
    private let analytics = InputAnalyticsTracker.shared
    

    
    enum Mode: Equatable {
        case add(Student, Date)
        case edit(UnsavedNote)
        
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
    let onSave: (UnsavedNote) -> Void
    
    init(mode: Mode, onSave: @escaping (UnsavedNote) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        switch mode {
        case .add:
            _textNote = State(initialValue: "")
        case .edit(let note):
            _textNote = State(initialValue: note.note)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(isAddMode ? "Tambah Catatan" : "Edit Catatan")
                    .foregroundStyle(.labelPrimaryBlack)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.cardFieldBG)
                        .frame(maxWidth: .infinity, maxHeight: 170)
                    
                    if textNote.isEmpty {
                        Text("Tuliskan catatan untuk murid...")
                            .font(.callout)
                            .fontWeight(.regular)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity, maxHeight: 170, alignment: .topLeading)
                            .foregroundColor(.labelDisabled)
                            .cornerRadius(8)
                    }
                    
                    TextEditor(text: $textNote)
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
                    Text(isAddMode ? "Tambah Catatan" : "Edit Catatan")
                        .foregroundStyle(.labelPrimaryBlack)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
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
                        if textNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
    
    private var isAddMode: Bool {
        switch mode {
        case .add: return true
        case .edit: return false
        }
    }
    
    private func saveNote() {
        switch mode {
        case .add(let student, let selectedDate):
            let newNote = UnsavedNote(
                note: textNote,
                createdAt: selectedDate,
                studentId: student.id
            )
            let properties: [String: MixpanelType] = [
                           "student_id": student.id.uuidString,
                           "note_length": textNote.count,
                           "created_at": selectedDate.timeIntervalSince1970,
                           "screen": "add_note",
                           "timestamp": Date().timeIntervalSince1970
                       ]
                       analytics.trackEvent("Note Created", properties: properties)
            onSave(newNote)
            
        case .edit(let note):
            let updatedNote = UnsavedNote(
                id: note.id,
                note: textNote,
                createdAt: note.createdAt,
                studentId: note.studentId
            )
            
            let properties: [String: MixpanelType] = [
                           "student_id": note.studentId.uuidString,
                           "note_id": note.id.uuidString,
                           "old_length": note.note.count,
                           "new_length": textNote.count,
                           "screen": "edit_note",
                           "timestamp": Date().timeIntervalSince1970
                       ]
                       analytics.trackEvent("Note Updated", properties: properties)
            onSave(updatedNote)
        }
        presentationMode.wrappedValue.dismiss()
    }
    
}


#Preview {
    ManageUnsavedNoteView(mode: .add(.init(fullname: "Rangga Biner", nickname: "Rangga"), .now), onSave: { _ in print("saved")})
}
