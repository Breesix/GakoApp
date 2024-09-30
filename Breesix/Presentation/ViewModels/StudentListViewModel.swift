//
//  StudentListViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation

@MainActor
class StudentListViewModel: ObservableObject {
    @Published var students: [Student] = []
    private let studentUseCases: StudentUseCase
    private let noteUseCases: NoteUseCase
    
    init(studentUseCases: StudentUseCase, noteUseCases: NoteUseCase) {
        self.studentUseCases = studentUseCases
        self.noteUseCases = noteUseCases
    }
    
    func loadStudents() async {
        do {
            students = try await studentUseCases.getAllStudents()
        } catch {
            print("Error loading students: \(error)")
        }
    }
    
    func addStudent(_ student: Student) async {
        do {
            try await studentUseCases.addStudent(student)
            await loadStudents()
        } catch {
            print("Error adding student: \(error)")
        }
    }
    
    func updateStudent(_ student: Student) async {
        do {
            try await studentUseCases.updateStudent(student)
            await loadStudents()
        } catch {
            print("Error updating student: \(error)")
        }
    }
    
    func deleteStudent(_ student: Student) async {
        do {
            try await studentUseCases.deleteStudent(student)
            await loadStudents()
        } catch {
            print("Error deleting student: \(error)")
        }
    }
    
    func addNote(_ note: Note, for student: Student) async {
        do {
            try await noteUseCases.addNote(note, for: student)
            await loadStudents() 
        } catch {
            print("Error adding note: \(error)")
        }
    }

    func getNotesForStudent(_ student: Student) async -> [Note] {
        do {
            return try await noteUseCases.getNotesForStudent(student)
        } catch {
            print("Error getting notes: \(error)")
            return []
        }
    }
    
    func updateNote(_ note: Note) async {
        do {
            try await noteUseCases.updateNote(note)
            await loadStudents()
        } catch {
            print("Error updating note: \(error)")
        }
    }
    
    func deleteNote(_ note: Note, from student: Student) async {
        do {
            try await noteUseCases.deleteNote(note, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].notes.removeAll(where: { $0.id == note.id })
            }
        } catch {
            print("Error deleting note: \(error)")
        }
    }

}
