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
    @Published var unsavedActivities: [UnsavedActivity] = []
    @Published var toiletTrainings: [ToiletTraining] = []
    private let studentUseCases: StudentUseCase
    private let activityUseCases: ActivityUseCase
    private let toiletTrainingUseCases: ToiletTrainingUseCase
    
    init(studentUseCases: StudentUseCase, activityUseCases: ActivityUseCase, toiletTrainingUseCases: ToiletTrainingUseCase) {
        self.studentUseCases = studentUseCases
        self.activityUseCases = activityUseCases
        self.toiletTrainingUseCases = toiletTrainingUseCases
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
    
    func addActivity(_ activity: Activity, for student: Student) async {
        do {
            try await activityUseCases.addActivity(activity, for: student)
            await loadStudents()
        } catch {
            print("Error adding activity: \(error)")
        }
    }
    
    func getActivitiesForStudent(_ student: Student) async -> [Activity] {
        do {
            return try await activityUseCases.getActivitiesForStudent(student)
        } catch {
            print("Error getting activities: \(error)")
            return []
        }
    }
    
    func getToiletTrainingForStudent(_ student: Student) async -> [ToiletTraining] {
        do {
            return try await toiletTrainingUseCases.getTrainingForStudent(student)
        } catch {
            print("Error getting toilet training: \(error)")
            return []
        }
    }
    
    func updateActivity(_ activity: Activity) async {
        do {
            try await activityUseCases.updateActivity(activity)
            await loadStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }
    
    func deleteActivity(_ activity: Activity, from student: Student) async {
        do {
            try await activityUseCases.deleteActivity(activity, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].activities.removeAll(where: { $0.id == activity.id })
            }
        } catch {
            print("Error deleting activity: \(error)")
        }
    }
    
    func addUnsavedActivities(_ activities: [UnsavedActivity]) {
        unsavedActivities.append(contentsOf: activities)
    }
    
    func clearUnsavedActivities() {
        unsavedActivities.removeAll()
    }
    
    func saveUnsavedActivities() async {
        for unsavedActivity in unsavedActivities {
            if let student = students.first(where: { $0.id == unsavedActivity.studentId }) {
                let activity = Activity(generalActivity: unsavedActivity.generalActivity, createdAt: unsavedActivity.createdAt, student: student)
                await addActivity(activity, for: student)
            }
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
    
    func addUnsavedActivity(_ activity: UnsavedActivity) {
        unsavedActivities.append(activity)
    }
    
    
    func addToiletTraining(_ toiletTrainingsInput: [ToiletTraining]) {
        toiletTrainings.append(contentsOf: toiletTrainingsInput)
    }
    
    func clearToiletTrainings() {
        toiletTrainings.removeAll()
    }
    
    func saveToiletTrainings() async {
        for training in toiletTrainings {
            let student = students.first(where: { $0 == training.student })
            do {
                let toiletTrainingObj = ToiletTraining(trainingDetail: training.trainingDetail, student: training.student, status: training.status!)
                await addToiletTraining(toiletTrainingObj, for: student!)
            } catch {
                print("Error saving toilet training: \(error)")
            }
        }
        clearToiletTrainings()
    }
    
    func updateToiletTraining(_ training: ToiletTraining) {
        if let index = toiletTrainings.firstIndex(where: { $0.id == training.id }) {
            toiletTrainings[index] = training
        }
    }
    
    func deleteToiletTraining(_ training: ToiletTraining) {
        toiletTrainings.removeAll { $0.id == training.id }
    }
    
    func addToiletTraining(_ training: ToiletTraining, for student: Student) async {
        do {
            try await toiletTrainingUseCases.addTraining(training, for: student)
            await loadStudents()
        } catch {
            print("Error adding training: \(error)")
        }
    }
}
