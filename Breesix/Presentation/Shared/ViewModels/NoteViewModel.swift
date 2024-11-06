//
//  NoteViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation
import SwiftUI

@MainActor
class NoteViewModel: ObservableObject {
    @Published var unsavedNotes: [UnsavedNote] = []
    @ObservedObject var studentViewModel: StudentViewModel
    private let noteUseCases: NoteUseCase
    
    init(unsavedNotes: [UnsavedNote] = [], studentViewModel: StudentViewModel, noteUseCases: NoteUseCase) {
        self.unsavedNotes = unsavedNotes
        self.studentViewModel = studentViewModel
        self.noteUseCases = noteUseCases
    }
    
    func addNote(_ note: Note, for student: Student) async {
        do {
            try await noteUseCases.addNote(note, for: student)
            await studentViewModel.fetchAllStudents()
        } catch {
            print("Error adding note: \(error)")
        }
    }
    
    func fetchAllNotes(_ student: Student) async -> [Note] {
        do {
            return try await noteUseCases.fetchAllNotes(student)
        } catch {
            print("Error getting activities: \(error)")
            return []
        }
    }
    
    func updateNote(_ note: Note) async {
        do {
            try await noteUseCases.updateNote(note)
            await studentViewModel.fetchAllStudents()
        } catch {
            print("Error updating note: \(error)")
        }
    }
    
    func deleteNote(_ note: Note, from student: Student) async {
        do {
            try await noteUseCases.deleteNote(note, from: student)
            if let index = studentViewModel.students.firstIndex(where: { $0.id == student.id }) {
                studentViewModel.students[index].notes.removeAll(where: { $0.id == note.id })
            }
        } catch {
            print("Error deleting note: \(error)")
        }
    }
    
    func addUnsavedNotes(_ notes: [UnsavedNote]) {
        unsavedNotes.append(contentsOf: notes)
    }
    
    func clearUnsavedNotes() {
        unsavedNotes.removeAll()
    }
    
    func saveUnsavedNotes() async {
        for unsavedNote in unsavedNotes {
            if let student = studentViewModel.students.first(where: { $0.id == unsavedNote.studentId }) {
                let note = Note(note: unsavedNote.note, createdAt: unsavedNote.createdAt, student: student)
                await addNote(note, for: student)
            }
        }
    }
    
    
    func updateUnsavedNote(_ note: UnsavedNote) {
        if let index = unsavedNotes.firstIndex(where: { $0.id == note.id }) {
            unsavedNotes[index] = note
            objectWillChange.send()
        }
    }
    
    func deleteUnsavedNote(_ note: UnsavedNote) {
        unsavedNotes.removeAll { $0.id == note.id }
        objectWillChange.send()
    }

    
    func addUnsavedNote(_ note: UnsavedNote) {
        unsavedNotes.append(note)
    }


}
