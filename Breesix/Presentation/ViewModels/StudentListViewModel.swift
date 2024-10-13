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
    @Published var unsavedNotes: [UnsavedNote] = []
    @Published var unsavedActivities: [UnsavedActivity] = []
    @Published var selectedDate: Date = Date() 
    private let studentUseCases: StudentUseCase
    private let noteUseCases: NoteUseCase
    private let activityUseCases: ActivityUseCase
    
    init(studentUseCases: StudentUseCase, noteUseCases: NoteUseCase, activityUseCases: ActivityUseCase) {
        self.studentUseCases = studentUseCases
        self.noteUseCases = noteUseCases
        self.activityUseCases = activityUseCases

    }
    
    func fetchAllStudents() async {
        do {
            students = try await studentUseCases.fetchAllStudents()
        } catch {
            print("Error loading students: \(error)")
        }
    }
    
    func addStudent(_ student: Student) async {
        do {
            try await studentUseCases.addStudent(student)
            await fetchAllStudents()
        } catch {
            print("Error adding student: \(error)")
        }
    }
    
    func updateStudent(_ student: Student) async {
        do {
            try await studentUseCases.updateStudent(student)
            await fetchAllStudents()
        } catch {
            print("Error updating student: \(error)")
        }
    }
    
    func deleteStudent(_ student: Student) async {
        do {
            try await studentUseCases.deleteStudent(student)
            await fetchAllStudents()
        } catch {
            print("Error deleting student: \(error)")
        }
    }
    
    func addNote(_ note: Note, for student: Student) async {
        do {
            try await noteUseCases.addNote(note, for: student)
            await fetchAllStudents()
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
            await fetchAllStudents()
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
    
    func fetchActivities(_ student: Student) async -> [Activity] {
        do {
            return try await activityUseCases.fetchActivities(student)
        } catch {
            print("Error getting activity: \(error)")
            return []
        }
    }
    
    func deleteActivities(_ activity: Activity, from student: Student) async {
        do {
            try await activityUseCases.deleteActivity(activity, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].activities.removeAll(where: { $0.id == activity.id })
            }
        } catch {
            print("Error deleting activity: \(error)")
        }
    }
    
    func addUnsavedNotes(_ notes: [UnsavedNote]) {
            unsavedNotes.append(contentsOf: notes)
    }
    
    func clearUnsavedNotes() {
        unsavedNotes.removeAll()
    }
    
    func saveUnsavedNotes() async {
        for UnsavedNote in unsavedNotes {
            if let student = students.first(where: { $0.id == UnsavedNote.studentId }) {
                let note = Note(note: UnsavedNote.note, createdAt: UnsavedNote.createdAt, student: student)
                await addNote(note, for: student)
            }
        }
        clearUnsavedNotes()
    }
    
    
    func updateUnsavedNote(_ note: UnsavedNote) {
        if let index = unsavedNotes.firstIndex(where: { $0.id == note.id }) {
            unsavedNotes[index] = note
        }
    }
    
    func deleteUnsavedNote(_ note: UnsavedNote) {
        unsavedNotes.removeAll { $0.id == note.id }
    }
    
    func addUnsavedNote(_ note: UnsavedNote) {
        unsavedNotes.append(note)
    }
    
    func addUnsavedActivities(_ activities: [UnsavedActivity]) {
        unsavedActivities.append(contentsOf: activities)
    }
    
    func clearUnsavedActivities() {
        unsavedActivities.removeAll()
    }
    
    func saveUnsavedActivities() async {
        for unsavedActivity in unsavedActivities {
            let student = students.first(where: { $0.id == unsavedActivity.studentId })
                let activityObj = Activity(activity: unsavedActivity.activity, createdAt: unsavedActivity.createdAt, isIndependent: unsavedActivity.isIndependent ?? false, student: student)
                await addActivity(activityObj, for: student!)
        }
        clearUnsavedActivities()
    }
    
    func updateUnsavedActivity(_ activity: UnsavedActivity) {
        if let index = unsavedActivities.firstIndex(where: { $0.id == activity.id }) {
            unsavedActivities[index] = activity
        }
    }
    
    func deleteUnsavedActivity(_ activity: UnsavedActivity) {
        unsavedActivities.removeAll { $0.id == activity.id }
    }
    
    func addActivity(_ activity: Activity, for student: Student) async {
        do {
            try await activityUseCases.addActivity(activity, for: student)
            await fetchAllStudents()
        } catch {
            print("Error adding activity: \(error)")
        }
    }
    
    func updateActivity(_ activity: Activity) async {
        do {
            try await activityUseCases.updateActivity(activity)
            await fetchAllStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }

}
