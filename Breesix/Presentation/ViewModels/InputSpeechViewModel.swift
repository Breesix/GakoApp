//
//  InputSpeechViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 15/10/24.
//

import Foundation
import SwiftUI
import Speech
import SwiftData

class InputSpeechViewModel: ObservableObject {
    @ObservedObject var viewModel: StudentListViewModel
    @Binding var isAllStudentsFilled: Bool
    @Published var reflection: String = ""
    @Published var isLoading: Bool = false
    @Published var isRecord: Bool = false
    @Published var isPaused: Bool = false
    @Published var hasSpeechPermission: Bool = false
    @Published var hasMicPermission: Bool = false
    @Published var errorMessage: String?
    @Published var students: [Student] = []
    @Published var unsavedNotes: [UnsavedNote] = []

    private let ttProcessor = OpenAIService(apiToken: "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")

    private let reflectionProcessor = ReflectionProcessor(apiToken: "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")
    var selectedDate: Date = Date()
    var onDismiss: () -> Void
    
    private var studentUseCases: StudentUseCase
    private let noteUseCases: NoteUseCase
    private var activityUseCases: ActivityUseCase

    private var speechRecognizer = SpeechRecognizer()
    
    init(studentUseCases: StudentUseCase, noteUseCases: NoteUseCase, activityUseCases: ActivityUseCase, isAllStudentsFilled: Binding<Bool>, viewModel: StudentListViewModel, onDismiss: @escaping () -> Void) {
        self.studentUseCases = studentUseCases
        self.noteUseCases = noteUseCases
        self.activityUseCases = activityUseCases
        self._isAllStudentsFilled = isAllStudentsFilled
        self.viewModel = viewModel
        self.onDismiss = onDismiss

        // Panggil requestPermissions setelah semua properti diinisialisasi
        DispatchQueue.main.async {
            self.requestPermissions()
        }
    }

    
    func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.hasSpeechPermission = true
                default:
                    self.hasSpeechPermission = false
                }
            }
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            DispatchQueue.main.async {
                self.hasMicPermission = allowed
            }
        }
    }
    
    func fetchAllStudents() async {
        do {
            students = try await studentUseCases.fetchAllStudents()
        } catch {
            print("Error loading students: \(error)")
        }
    }
    
    func startRecording() {
        if hasSpeechPermission && hasMicPermission {
            isRecord = true
            isPaused = false
            speechRecognizer.startTranscribing()
            updateReflection()
        }
    }
    
    func stopRecording() {
        isRecord = false
        isPaused = false
        speechRecognizer.stopTranscribing()
        reflection = speechRecognizer.transcript
    }
    
    func pauseRecording() {
        isPaused = true
        speechRecognizer.pauseTranscribing()
    }
    
    func resumeRecording() {
        isPaused = false
        speechRecognizer.resumeTranscribing()
    }
    
    private func updateReflection() {
        speechRecognizer.$transcript
            .receive(on: RunLoop.main)
            .assign(to: &$reflection)
    }
    
    func processReflectionActivity() {
        Task {
            do {
                isLoading = true
                errorMessage = nil

                await fetchAllStudents()

                let csvString = try await ttProcessor.processReflection(reflection: reflection, students: viewModel.students)

                let (activityList, noteList) = TTCSVParser.parseActivitiesAndNotes(csvString: csvString, students: viewModel.students, createdAt: selectedDate)

                await MainActor.run {
                    isLoading = false
                    isAllStudentsFilled = true
                    
                    viewModel.addUnsavedActivities(activityList)
                    viewModel.addUnsavedNotes(noteList)

                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    print("Error in processReflection: \(error)")
                }
            }
        }
    }
}

