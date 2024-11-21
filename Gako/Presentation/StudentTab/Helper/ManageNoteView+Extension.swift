//
//  ManageNoteView+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//

import Foundation

extension ManageNoteView {
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
    
    func saveNote() {
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
