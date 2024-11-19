//
//  ActivityViewModel.swift
//  Gako
//
//  Created by Rangga Biner on 03/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: ViewModel for managing student activities and their states
//  Usage: Handles activity-related operations including CRUD operations, temporary storage, and synchronization with the backend
//

import Foundation
import SwiftUI

@MainActor
class ActivityViewModel: ObservableObject {
    @Published var unsavedActivities: [UnsavedActivity] = []
    @ObservedObject var studentViewModel: StudentViewModel
    private let activityUseCases: ActivityUseCase
    
    init(unsavedActivities: [UnsavedActivity] = [], studentViewModel: StudentViewModel, activityUseCases: ActivityUseCase) {
        self.unsavedActivities = unsavedActivities
        self.studentViewModel = studentViewModel
        self.activityUseCases = activityUseCases
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
                let activity = Activity(activity: unsavedActivity.activity, createdAt: unsavedActivity.createdAt, status: unsavedActivity.status, student: student)
                await addActivity(activity, for: student)
            }
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
    
    func updateActivityStatus(_ activity: Activity, status: Status) async {
        do {
           
            let updatedActivity = Activity(
                id: activity.id,
                activity: activity.activity,
                createdAt: activity.createdAt,
                status: status,
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
