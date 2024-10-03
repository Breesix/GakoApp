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
    private let studentUseCases: StudentUseCase
    private let activityUseCases: ActivityUseCase

    init(studentUseCases: StudentUseCase, activityUseCases: ActivityUseCase) {
        self.studentUseCases = studentUseCases
        self.activityUseCases = activityUseCases
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
}
