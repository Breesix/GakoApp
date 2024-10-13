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
    @Published var unsavedToiletTrainings: [UnsavedActivity] = []
    @Published var selectedDate: Date = Date() 
    private let studentUseCases: StudentUseCase
    private let noteUseCases: NoteUseCase
    private let toiletTrainingUseCases: ActivityUseCase
    
    init(studentUseCases: StudentUseCase, noteUseCases: NoteUseCase, toiletTrainingUseCases: ActivityUseCase) {
        self.studentUseCases = studentUseCases
        self.noteUseCases = noteUseCases

//        Task {
//            await loadStudents() /
//        }

        self.toiletTrainingUseCases = toiletTrainingUseCases

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
    
    func getToiletTrainingForStudent(_ student: Student) async -> [Activity] {
        do {
            return try await toiletTrainingUseCases.fetchActivities(student)
        } catch {
            print("Error getting activity: \(error)")
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
    
    func deleteToiletTraining(_ toiletTraining: Activity, from student: Student) async {
        do {
            try await toiletTrainingUseCases.deleteActivity(toiletTraining, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].activities.removeAll(where: { $0.id == toiletTraining.id })
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
    
    func addUnsavedToiletTraining(_ toiletTrainingsInput: [UnsavedActivity]) {
        unsavedToiletTrainings.append(contentsOf: toiletTrainingsInput)
    }
    
    func clearUnsavedToiletTrainings() {
        unsavedNotes.removeAll()
    }
    
    func saveUnsavedToiletTrainings() async {
        for unsavedTraining in unsavedToiletTrainings {
            let student = students.first(where: { $0.id == unsavedTraining.studentId })
            do {
                let toiletTrainingObj = Activity(trainingDetail: unsavedTraining.activity, createdAt: unsavedTraining.createdAt, status: unsavedTraining.isIndependent!, student: student)
                await addToiletTraining(toiletTrainingObj, for: student!)
            } catch {
                print("Error saving toilet activity: \(error)")
            }
        }
        clearUnsavedNotes()
    }

    
//    func clearToiletTrainings() {
//        toiletTrainings.removeAll()
//    }
    
//    func saveToiletTrainings() async {
//        for training in toiletTrainings {
//            let student = students.first(where: { $0 == training.student })
//            do {
//                let toiletTrainingObj = ToiletTraining(trainingDetail: training.trainingDetail, createdAt: training.createdAt, status: training.status!, student: training.student)
//                await addToiletTraining(toiletTrainingObj, for: student!)
//            } catch {
//                print("Error saving toilet training: \(error)")
//            }
//        }
//        clearToiletTrainings()
//    }

    
    func updateUnsavedToiletTraining(_ training: UnsavedActivity) {
        if let index = unsavedToiletTrainings.firstIndex(where: { $0.id == training.id }) {
            unsavedToiletTrainings[index] = training
        }
    }
    
    func deleteUnsavedToiletTraining(_ training: UnsavedActivity) {
        unsavedToiletTrainings.removeAll { $0.id == training.id }
    }
    
    func addToiletTraining(_ training: Activity, for student: Student) async {
        do {
            try await toiletTrainingUseCases.addActivity(training, for: student)
            await fetchAllStudents()
        } catch {
            print("Error adding activity: \(error)")
        }
    }
    
    func updateTraining(_ training: Activity) async {
        do {
            try await toiletTrainingUseCases.updateActivity(training)
            await fetchAllStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }

}
