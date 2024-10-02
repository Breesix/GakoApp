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
    private let generalActivityUseCases: GeneralActivityUseCase
    
    init(studentUseCases: StudentUseCase, generalActivityUseCases: GeneralActivityUseCase) {
        self.studentUseCases = studentUseCases
        self.generalActivityUseCases = generalActivityUseCases
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
            try await generalActivityUseCases.addActivity(activity, for: student)
            await loadStudents()
        } catch {
            print("Error adding note: \(error)")
        }
    }

    func getActivitiesForStudent(_ student: Student) async -> [Activity] {
        do {
            return try await generalActivityUseCases.getActivitiesForStudent(student)
        } catch {
            print("Error getting notes: \(error)")
            return []
        }
    }
    
    func updateActivity(_ activity: Activity) async {
        do {
            try await generalActivityUseCases.updateActivity(activity)
            await loadStudents()
        } catch {
            print("Error updating note: \(error)")
        }
    }
    
    func deleteActivity(_ activity: Activity, from student: Student) async {
        do {
            try await generalActivityUseCases.deleteActivity(activity, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].notes.removeAll(where: { $0.id == activity.id })
            }
        } catch {
            print("Error deleting note: \(error)")
        }
    }

}
