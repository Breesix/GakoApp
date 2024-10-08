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
    @Published var unsavedToiletTrainings: [UnsavedToiletTraining] = []
    private let studentUseCases: StudentUseCase
    private let activityUseCases: ActivityUseCase
    private let toiletTrainingUseCases: ToiletTrainingUseCase
    private let summaryUseCase: SummaryUseCase
    private let summarizationService: SummarizationService

    init(studentUseCases: StudentUseCase, activityUseCases: ActivityUseCase, toiletTrainingUseCases: ToiletTrainingUseCase, summarizationService: SummarizationService, summaryUseCase: SummaryUseCase) {
        self.studentUseCases = studentUseCases
        self.activityUseCases = activityUseCases
        self.toiletTrainingUseCases = toiletTrainingUseCases
        self.summarizationService = summarizationService
        self.summaryUseCase = summaryUseCase
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
    
    func deleteSummary(_ summary: WeeklySummary, from student: Student) async {
        do {
            try await summaryUseCase.deleteSummary(summary, from: student)
            if let index = students.firstIndex(where: { $0.id == student.id }) {
                students[index].weeklySummaries.removeAll(where: { $0.id == summary.id })
            }
        } catch {
            print("Error deleting activity: \(error)")
        }
    }
    
    func deleteToiletTraining(_ toiletTraining: ToiletTraining, from student: Student) async {
        do {
            try await toiletTrainingUseCases.deleteTrainingProgress(toiletTraining, from: student)
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
            try await toiletTrainingUseCases.addTraining(training, for: student)
            await loadStudents()
        } catch {
            print("Error adding training: \(error)")
        }
    }
    
    func updateTraining(_ training: ToiletTraining) async {
        do {
            try await toiletTrainingUseCases.updateTrainingProgress(training)
            await loadStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }
    
    func generateAndSaveWeeklySummary(for student: Student, startDate: Date, endDate: Date, title: String) async throws {
        let activities = await getActivitiesForStudent(student)
        let toiletTrainings = await getToiletTrainingForStudent(student)
        
        let filteredActivities = activities.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }
        let filteredToiletTrainings = toiletTrainings.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }
        
        let summaryText = try await summarizationService.generateWeeklySummary(
            activities: filteredActivities,
            toiletTrainings: filteredToiletTrainings,
            student: student,
            startDate: startDate,
            endDate: endDate
        )
        
        // Create a new WeeklySummary with createdAt and title set appropriately
        let weeklySummary = WeeklySummary(startDate: startDate, endDate: endDate, summary: summaryText, createdAt: Date(), title: title, student: student)
        try await saveWeeklySummary(weeklySummary, for: student)
    }

    func saveWeeklySummary(_ summary: WeeklySummary, for student: Student) async throws {
        do {
            student.weeklySummaries.append(summary)
            try await studentUseCases.updateStudent(student)
            await loadStudents()
        } catch {
            print("Error saving weekly summary: \(error)")
            throw error
        }
    }

    func getWeeklySummariesForStudent(_ student: Student) -> [WeeklySummary] {
        return student.weeklySummaries.sorted(by: { $0.endDate > $1.endDate })
    }

}

enum SummaryTimeRange {
    case lastWeek
    case lastMonth
    case lastThreeMonths
    case lastSixMonths
    case allTime
    
    var title: String {
        switch self {
        case .lastWeek: return "Last 7 Days"
        case .lastMonth: return "Last 30 Days"
        case .lastThreeMonths: return "Last 3 Months"
        case .lastSixMonths: return "Last 6 Months"
        case .allTime: return "All Time"
        }
    }
}
