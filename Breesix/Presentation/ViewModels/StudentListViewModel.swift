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
//    @Published var toiletTrainings: [ToiletTraining] = []
    @Published var unsavedToiletTrainings: [UnsavedToiletTraining] = []
    @Published var selectedDate: Date = Date() 
    private let studentUseCases: StudentUseCase
    private let activityUseCases: ActivityUseCase
    private let toiletTrainingUseCases: ToiletTrainingUseCase
    
    init(studentUseCases: StudentUseCase, activityUseCases: ActivityUseCase, toiletTrainingUseCases: ToiletTrainingUseCase) {
        self.studentUseCases = studentUseCases
        self.activityUseCases = activityUseCases

//        Task {
//            await loadStudents() /
//        }

        self.toiletTrainingUseCases = toiletTrainingUseCases

    }
    
    func loadStudents() async {
        do {
            students = try await studentUseCases.fetchAllStudents()
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
            return try await activityUseCases.fetchAllActivities(student)
        } catch {
            print("Error getting activities: \(error)")
            return []
        }
    }
    
    func getToiletTrainingForStudent(_ student: Student) async -> [ToiletTraining] {
        do {
            return try await toiletTrainingUseCases.fetchToiletTrainings(student)
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
    
    func deleteToiletTraining(_ toiletTraining: ToiletTraining, from student: Student) async {
        do {
            try await toiletTrainingUseCases.deleteToiletTraining(toiletTraining, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].toiletTrainings.removeAll(where: { $0.id == toiletTraining.id })
            }
        } catch {
            print("Error deleting toilet training: \(error)")
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
    
    func addUnsavedToiletTraining(_ toiletTrainingsInput: [UnsavedToiletTraining]) {
        unsavedToiletTrainings.append(contentsOf: toiletTrainingsInput)
    }
    
    func clearUnsavedToiletTrainings() {
        unsavedActivities.removeAll()
    }
    
    func saveUnsavedToiletTrainings() async {
        for unsavedTraining in unsavedToiletTrainings {
            let student = students.first(where: { $0.id == unsavedTraining.studentId })
            do {
                let toiletTrainingObj = ToiletTraining(trainingDetail: unsavedTraining.trainingDetail, createdAt: unsavedTraining.createdAt, status: unsavedTraining.status!, student: student)
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

    
    func updateUnsavedToiletTraining(_ training: UnsavedToiletTraining) {
        if let index = unsavedToiletTrainings.firstIndex(where: { $0.id == training.id }) {
            unsavedToiletTrainings[index] = training
        }
    }
    
    func deleteUnsavedToiletTraining(_ training: UnsavedToiletTraining) {
        unsavedToiletTrainings.removeAll { $0.id == training.id }
    }
    
    func addToiletTraining(_ training: ToiletTraining, for student: Student) async {
        do {
            try await toiletTrainingUseCases.addToiletTraining(training, for: student)
            await loadStudents()
        } catch {
            print("Error adding training: \(error)")
        }
    }
    
    func updateTraining(_ training: ToiletTraining) async {
        do {
            try await toiletTrainingUseCases.updateToiletTraining(training)
            await loadStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }

}
