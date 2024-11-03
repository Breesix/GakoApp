//
//  StudentTabViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftUI

@MainActor
class StudentTabViewModel: ObservableObject {
    @ObservedObject var studentViewModel: StudentViewModel
    @Published var unsavedActivities: [UnsavedActivity] = []
    @Published var selectedDate: Date = Date()
    private let activityUseCases: ActivityUseCase
    private let summaryService: SummaryService
    private let summaryLlamaService: SummaryLlamaService
    private let summaryUseCase: SummaryUseCase
    
    init(studentViewModel: StudentViewModel, activityUseCases: ActivityUseCase, summaryUseCase: SummaryUseCase, summaryService: SummaryService, summaryLlamaService: SummaryLlamaService) {
        self.studentViewModel = studentViewModel
        self.activityUseCases = activityUseCases
        self.summaryUseCase = summaryUseCase
        self.summaryService = summaryService
        self.summaryLlamaService = summaryLlamaService
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
            await MainActor.run {
                if let index = studentViewModel.students.firstIndex(where: { $0.id == student.id }) {
                    studentViewModel.students[index].activities.removeAll(where: { $0.id == activity.id })
                }
                objectWillChange.send()
            }
        } catch {
            print("Error deleting activity: \(error)")
        }
    }
    
    func addUnsavedActivity(_ activity: UnsavedActivity) {
        unsavedActivities.append(activity)
    }
    
    
    func addUnsavedActivities(_ activities: [UnsavedActivity]) {
        unsavedActivities.append(contentsOf: activities)
    }
    
    func clearUnsavedActivities() {
        unsavedActivities.removeAll()
    }
    
    func saveUnsavedActivities() async {
        for unsavedActivity in unsavedActivities {
            if let student = studentViewModel.students.first(where: { $0.id == unsavedActivity.studentId }) {
                let activity = Activity(activity: unsavedActivity.activity, createdAt: unsavedActivity.createdAt, isIndependent: unsavedActivity.isIndependent ?? nil, student: student)
                await addActivity(activity, for: student)
            }
        }
        await MainActor.run {
            self.clearUnsavedActivities()
        }
    }
    
    
    
    func updateUnsavedActivity(_ activity: UnsavedActivity) {
        if let index = unsavedActivities.firstIndex(where: { $0.id == activity.id }) {
            unsavedActivities[index] = activity
            objectWillChange.send()
        }
    }
    
    
    func deleteUnsavedActivity(_ activity: UnsavedActivity) {
        withAnimation {
            unsavedActivities.removeAll { $0.id == activity.id }
            objectWillChange.send()
        }
    }

    
    func addActivity(_ activity: Activity, for student: Student) async {
        do {
            try await activityUseCases.addActivity(activity, for: student)
            await studentViewModel.fetchAllStudents()
        } catch {
            print("Error adding activity: \(error)")
        }
    }
    
    
    
    func updateActivity(_ activity: Activity) async {
        do {
            try await activityUseCases.updateActivity(activity)
            await studentViewModel.fetchAllStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }
    
    func generateAndSaveSummaries(for date: Date) async throws {
        try await summaryService.generateAndSaveSummaries(for: studentViewModel.students, on: date)
    }
    
    func generateAndSaveSummariesLlama(for date: Date) async throws {
        try await summaryLlamaService.generateAndSaveSummaries(for: studentViewModel.students, on: date)
    }
    
    func updateActivityStatus(_ activity: Activity, isIndependent: Bool?) async {
        do {
           
            let updatedActivity = Activity(
                id: activity.id,
                activity: activity.activity,
                createdAt: activity.createdAt,
                isIndependent: isIndependent,
                student: activity.student!
            )
    
            try await activityUseCases.updateActivity(updatedActivity)
            
            if let student = activity.student {
                _ = await fetchActivities(student)
            }
        } catch {
            print("Error updating activity status: \(error)")
        }
    }
}
