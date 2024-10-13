//
//  InputView.swift
//  Breesix
//
//  Created by Akmal Hakim on 03/10/24.
//

import SwiftUI
import Speech

struct InputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @ObservedObject var speechRecognizer = SpeechRecognizer()
    @State private var selectedInputType: InputType = .manual
    @State private var isShowingPreview = false
    var inputType: InputType
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State var isFilledToday: Bool = false
    @State private var isRecord: Bool = false

    @Binding var isAllStudentsFilled: Bool

    let selectedDate: Date
    var onDismiss: () -> Void

    private let ttProcessor = OpenAIService(apiToken: "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")

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $reflection)
                    .padding()
                    .border(Color.gray, width: 1)

                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }

                if inputType == .speech {
                    if !isRecord {
                        Button(action: {
                            isRecord = true
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.speechRecognizer.startTranscribing()
                            }
                        }) {
                            Image("play-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .overlay {
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round))
                                        .foregroundColor(.black)
                                        .shadow(radius: 2)
                                }
                        }
                    } else {
                        Button(action: {
                            DispatchQueue.global(qos: .userInitiated).async {
                                self.speechRecognizer.stopTranscribing()
                                DispatchQueue.main.async {
                                    self.reflection = self.speechRecognizer.transcript
                                    isRecord = false
                                }
                            }
                        }) {
                            Image("stop-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .overlay {
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round))
                                        .foregroundColor(.black)
                                        .shadow(radius: 2)
                                }
                        }
                    }
                }

                Button("Next") {
                    processReflectionActivity()
                }
                .padding()
                .disabled(reflection.isEmpty || isLoading)
            }
            .navigationTitle("Ceritakan Aktivitas Hari Ini")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                resetIsFilledTodayIfNeeded()
                requestSpeechAuthorization()
            }
            .onReceive(speechRecognizer.$transcript) { newTranscript in
                self.reflection = newTranscript
            }
        }
    }

    func resetIsFilledTodayIfNeeded() {
        let lastResetDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastResetDate) {
            isFilledToday = false
            UserDefaults.standard.set(Date(), forKey: "lastResetDate")
        }
    }
    
    private func processReflectionActivity() {
        Task {
            do {
                isLoading = true
                errorMessage = nil

                await viewModel.fetchAllStudents()

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

    public func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied:
                print("Speech recognition denied")
            case .restricted:
                print("Speech recognition restricted")
            case .notDetermined:
                print("Speech recognition not determined")
            @unknown default:
                print("Unknown status")
            }
        }
    }
}

