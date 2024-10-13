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
    @Published var unsavedActivities: [UnsavedNote] = []
//    @Published var toiletTrainings: [ToiletTraining] = []
    @Published var unsavedToiletTrainings: [UnsavedActivity] = []
    @Published var selectedDate: Date = Date() 
    private let studentUseCases: StudentUseCase
    private let noteUseCases: NoteUseCase
    private let toiletTrainingUseCases: ActivityUseCase
    
    init(studentUseCases: StudentUseCase, activityUseCases: NoteUseCase, toiletTrainingUseCases: ActivityUseCase) {
        self.studentUseCases = studentUseCases
        self.noteUseCases = activityUseCases

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
            print("Error adding activity: \(error)")
        }
    }
    
    func getActivitiesForStudent(_ student: Student) async -> [Note] {
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
            print("Error getting toilet training: \(error)")
            return []
        }
    }
    
    func updateActivity(_ activity: Note) async {
        do {
            try await noteUseCases.updateNote(activity)
            await fetchAllStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }
    
    func deleteActivity(_ activity: Note, from student: Student) async {
        do {
            try await noteUseCases.deleteNote(activity, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].notes.removeAll(where: { $0.id == activity.id })
            }
        } catch {
            print("Error deleting activity: \(error)")
        }
    }
    
    func deleteToiletTraining(_ toiletTraining: Activity, from student: Student) async {
        do {
            try await toiletTrainingUseCases.deleteActivity(toiletTraining, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].activities.removeAll(where: { $0.id == toiletTraining.id })
            }
        } catch {
            print("Error deleting toilet training: \(error)")
        }
    }
    
    func addUnsavedActivities(_ activities: [UnsavedNote]) {
            unsavedActivities.append(contentsOf: activities)
    }
    
    func clearUnsavedActivities() {
        unsavedActivities.removeAll()
    }
    
    func saveUnsavedActivities() async {
        for UnsavedNote in unsavedActivities {
            if let student = students.first(where: { $0.id == UnsavedNote.studentId }) {
                let activity = Note(note: UnsavedNote.note, createdAt: UnsavedNote.createdAt, student: student)
                await addNote(activity, for: student)
            }
        }
        clearUnsavedActivities()
    }
    
    
    func updateUnsavedNote(_ activity: UnsavedNote) {
        if let index = unsavedActivities.firstIndex(where: { $0.id == activity.id }) {
            unsavedActivities[index] = activity
        }
    }
    
    func deleteUnsavedNote(_ activity: UnsavedNote) {
        unsavedActivities.removeAll { $0.id == activity.id }
    }
    
    func addUnsavedNote(_ activity: UnsavedNote) {
        unsavedActivities.append(activity)
    }
    
    func addUnsavedToiletTraining(_ toiletTrainingsInput: [UnsavedActivity]) {
        unsavedToiletTrainings.append(contentsOf: toiletTrainingsInput)
    }
    
    func clearUnsavedToiletTrainings() {
        unsavedActivities.removeAll()
    }
    
    func saveUnsavedToiletTrainings() async {
        for unsavedTraining in unsavedToiletTrainings {
            let student = students.first(where: { $0.id == unsavedTraining.studentId })
            do {
                let toiletTrainingObj = Activity(trainingDetail: unsavedTraining.activity, createdAt: unsavedTraining.createdAt, status: unsavedTraining.isIndependent!, student: student)
                await addToiletTraining(toiletTrainingObj, for: student!)
            } catch {
                print("Error saving toilet training: \(error)")
            }
        }
        clearUnsavedActivities()
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
            print("Error adding training: \(error)")
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
