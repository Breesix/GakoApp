//
//  InputViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import SwiftUI

class InputViewModel: ObservableObject {
    internal var inputStartTime: Date?
    internal let analytics: InputAnalyticsTracking
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    init(analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared) {
        self.analytics = analytics
    }

    func setLoading(_ loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.isLoading = loading
        }
    }
    func setError(_ error: String?) {
        DispatchQueue.main.async { [weak self] in
            self?.errorMessage = error
        }
    }

    func startInput(type: InputType, date: Date) {
        inputStartTime = Date()
        analytics.trackInputStarted(type: type, date: date)
    }

    func completeInput(type: InputType, text: String) {
        let duration = inputStartTime.map { Date().timeIntervalSince($0) }
        analytics.trackInputCompleted(
            type: type,
            success: true,
            duration: duration,
            textLength: text.count
        )
    }


    // Method to process reflection
    func processReflection(
            reflection: String,
            fetchStudents: @escaping () async -> [Student],
            onAddUnsavedActivities: @escaping ([UnsavedActivity]) -> Void,
            onAddUnsavedNotes: @escaping ([UnsavedNote]) -> Void,
            selectedDate: Date,
            onDateSelected: @escaping (Date) -> Void,
            onDismiss: @escaping () -> Void
        ) async {
            do {
                await MainActor.run {
                    self.isLoading = true
                    self.errorMessage = nil
                }
                analytics.trackProcessingStarted(type: .text)

                let students = await fetchStudents()

                if reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    await MainActor.run {
                        self.isLoading = false
                    }
                    return
                }

                let csvString = try await OpenAIService(apiToken: APIConfig.openAIToken)
                    .processReflection(reflection: reflection, students: students)

                let (activityList, noteList) = ReflectionCSVParser.parseActivitiesAndNotes(
                    csvString: csvString,
                    students: students,
                    createdAt: selectedDate
                )

                await MainActor.run {
                    self.isLoading = false
                    onAddUnsavedActivities(activityList)
                    onAddUnsavedNotes(noteList)
                    onDateSelected(selectedDate)
                    onDismiss()
                    
                    analytics.trackProcessingCompleted(
                        type: .text,
                        success: true,
                        studentsCount: students.count
                    )
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                    analytics.trackProcessingCompleted(
                        type: .text,
                        success: false,
                        studentsCount: 0
                    )
                }
            }
        }
    }
