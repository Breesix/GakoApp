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
    @Published var students: [Student] = []
    @Published var unsavedNotes: [UnsavedNote] = []
    @Published var unsavedActivities: [UnsavedActivity] = []
    @Published var summariesModel: [Summary] = []
    @Published var selectedDate: Date = Date()
    private let studentUseCases: StudentUseCase
    private let noteUseCases: NoteUseCase
    private let activityUseCases: ActivityUseCase
    private let summaryService: SummaryService
    private let summaryLlamaService: SummaryLlamaService
    private let summaryUseCase: SummaryUseCase

    @Published var newStudentImage: UIImage? {
        didSet {
            if let image = newStudentImage {
                self.compressedImageData = image.jpegData(compressionQuality: 0.8)
            } else {
                self.compressedImageData = nil
            }
        }
    }
    
    @Published private(set) var compressedImageData: Data?
    
    init(studentUseCases: StudentUseCase, noteUseCases: NoteUseCase, activityUseCases: ActivityUseCase, summaryUseCase: SummaryUseCase, summaryService: SummaryService, summaryLlamaService: SummaryLlamaService) {
        self.studentUseCases = studentUseCases
        self.noteUseCases = noteUseCases
        self.activityUseCases = activityUseCases
        self.summaryUseCase = summaryUseCase
        self.summaryService = summaryService
        self.summaryLlamaService = summaryLlamaService
    }
    
    @MainActor
    func fetchAllStudents() async {
        do {
            students = try await studentUseCases.fetchAllStudents()
        } catch {
            print("Error loading students: \(error)")
        }
    }
    
    @MainActor
    func addStudent(_ student: Student) async {
        do {
            let studentWithCompressedImage = Student(
                fullname: student.fullname,
                nickname: student.nickname,
                imageData: compressedImageData
            )
            
            try await studentUseCases.addStudent(studentWithCompressedImage)
            await fetchAllStudents()
            
            await MainActor.run {
                self.newStudentImage = nil
                self.compressedImageData = nil
            }
        } catch {
            print("Error adding student: \(error)")
        }
    }
    
    func updateStudent(_ student: Student) async {
        do {
            try await studentUseCases.updateStudent(student)
            await fetchAllStudents()
            
            // Tambahkan reset state
            await MainActor.run {
                self.newStudentImage = nil
                self.compressedImageData = nil
            }
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
                if let index = students.firstIndex(where: { $0.id == student.id }) {
                    students[index].activities.removeAll(where: { $0.id == activity.id })
                }
                objectWillChange.send()
            }
        } catch {
            print("Error deleting activity: \(error)")
        }
    }
    
    func addUnsavedNotes(_ notes: [UnsavedNote]) {
        unsavedNotes.append(contentsOf: notes)
    }
    
    func addSummaries(_ summaries: [Summary]) {
        summariesModel.append(contentsOf: summaries)
    }
    
    func clearUnsavedNotes() {
        unsavedNotes.removeAll()
    }
    
    func saveUnsavedNotes() async {
        for unsavedNote in unsavedNotes {
            if let student = students.first(where: { $0.id == unsavedNote.studentId }) {
                let note = Note(note: unsavedNote.note, createdAt: unsavedNote.createdAt, student: student)
                await addNote(note, for: student)
            }
        }
        await MainActor.run {
            self.clearUnsavedNotes()
        }
    }
    
    
    func updateUnsavedNote(_ note: UnsavedNote) {
        if let index = unsavedNotes.firstIndex(where: { $0.id == note.id }) {
            unsavedNotes[index] = note
            objectWillChange.send()
        }
    }
    
    func deleteUnsavedNote(_ note: UnsavedNote) {
        unsavedNotes.removeAll { $0.id == note.id }
        objectWillChange.send()
    }

    
    func addUnsavedNote(_ note: UnsavedNote) {
        unsavedNotes.append(note)
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
            if let student = students.first(where: { $0.id == unsavedActivity.studentId }) {
                let activity = Activity(activity: unsavedActivity.activity, createdAt: unsavedActivity.createdAt, isIndependent: unsavedActivity.isIndependent ?? false, student: student)
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
            await fetchAllStudents()
        } catch {
            print("Error adding activity: \(error)")
        }
    }
    
    
    
    func updateActivity(_ activity: Activity) async {
        do {
            try await activityUseCases.updateActivity(activity)
            await fetchAllStudents()
        } catch {
            print("Error updating activity: \(error)")
        }
    }
    
//    func generateAndSaveSummaries(for date: Date) async throws {
//        try await summaryService.generateAndSaveSummaries(for: students, on: date)
//    }
    
    func generateAndSaveSummariesLlama(for date: Date) async throws {
        try await summaryLlamaService.generateAndSaveSummaries(for: students, on: date)
    }
    
    func updateActivityStatus(_ activity: Activity, isIndependent: Bool) async {
        do {
            // Buat activity baru dengan status yang diperbarui
            let updatedActivity = Activity(
                id: activity.id,
                activity: activity.activity,
                createdAt: activity.createdAt,
                isIndependent: isIndependent,
                student: activity.student!
            )
            
            // Update activity menggunakan use case yang ada
            try await activityUseCases.updateActivity(updatedActivity)
            
            // Refresh data
            if let student = activity.student {
                _ = await fetchActivities(student)
            }
        } catch {
            print("Error updating activity status: \(error)")
        }
    }
}
