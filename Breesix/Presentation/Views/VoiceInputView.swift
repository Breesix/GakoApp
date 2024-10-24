//
//  InputVoiceView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//


import SwiftUI
import Speech

struct VoiceInputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @StateObject private var sumaryTabViewModel = SummaryTabViewModel()
    @ObservedObject var speechRecognizer = SpeechRecognizer()
    @State private var selectedInputType: InputType = .manual
    @State private var isShowingPreview = false
    var inputType: InputType
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State var isFilledToday: Bool = false
    @State private var isRecording = false
    @State private var isPaused = false
    @State private var isSaving = false
    @State private var showAlert: Bool = false
    @Binding var isAllStudentsFilled: Bool
    @FocusState private var isTextEditorFocused: Bool
    @State private var showProTips: Bool = true
    @State private var selectedDate: Date = Date()
    @State private var showTabBar = false
    
    
    var onDismiss: () -> Void
    
    private let ttProcessor = OpenAIService(apiToken: "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")
    
    var body: some View {
        ZStack{
            
            VStack(alignment: .center) {
                
                datePickerView()
                
                
                ZStack {
                    TextEditor(text: $reflection)
                        .disabled(isRecording)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scrollContentBackground(.hidden)
                        .lineSpacing(5)
                        .multilineTextAlignment(.leading)
                        .cornerRadius(10)
                        .focused($isTextEditorFocused)
                }
                
                if !isRecording  {
                    ProTipsCard()
                }
                
                Spacer()
                
                
                ZStack(alignment: .bottom) {
                    HStack(alignment: .center, spacing: 30) {
                        
                        Button(action: {
                            self.speechRecognizer.stopTranscribing()
                            showAlert = true
                            
                        }) {
                            Image("cancel-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        
                        
                        // Play/Pause Button
                        Button(action: {
                            if !isRecording {
                                // Start recording
                                isRecording = true
                                isPaused = false
                                self.speechRecognizer.startTranscribing()
                            } else {
                                // Toggle pause/resume
                                isPaused.toggle()
                                if isPaused {
                                    self.speechRecognizer.pauseTranscribing()
                                } else {
                                    self.speechRecognizer.resumeTranscribing()
                                }
                            }
                        }) {
                            if isSaving {
                                // Loading indicator
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 80)
                                    .overlay {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(1.5)
                                    }
                            } else {
                                // Play/Pause icon
                                Image(isRecording && !isPaused ? "pause-mic-button" : "play-mic-button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80)
                            }
                        }
                        .disabled(isSaving)
                        
                        // Save Button
                        Button(action: {
                            if isRecording {
                                isSaving = true
                                isRecording = false
                                self.speechRecognizer.stopTranscribing()
                                self.reflection = self.speechRecognizer.transcript
                                self.processReflectionActivity()
                            }
                        }) {
                            Image("save-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        .disabled(!isRecording || isSaving)
                    }
                    .padding(10)
                    
                }
            }
            .padding()
        }
        .hideTabBar()
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.all)
        .padding()
        .navigationBarBackButtonHidden(true)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Batalkan Dokumentasi?"),
                message: Text("Semua teks yang anda masukkan akan dihapus secara permanen"),
                primaryButton: .destructive(Text("Ya")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Tidak"))
            )
        }
        .onReceive(speechRecognizer.$transcript) { newTranscript in
            DispatchQueue.main.async {
                self.reflection = newTranscript
            }
        }
        .safeAreaPadding()
        .onAppear {
            resetIsFilledTodayIfNeeded()
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
                // Show the loading state immediately
                DispatchQueue.main.async {
                    isLoading = true
                    errorMessage = nil
                }
                
                await viewModel.fetchAllStudents()
                
                let csvString = try await ttProcessor.processReflection(reflection: reflection, students: viewModel.students)
                
                let (activityList, noteList) = TTCSVParser.parseActivitiesAndNotes(csvString: csvString, students: viewModel.students, createdAt: selectedDate)
                
                await MainActor.run {
                    DispatchQueue.main.async {
                        // Hide loading and update the view
                        isLoading = false
                        isAllStudentsFilled = true
                        
                        viewModel.addUnsavedActivities(activityList)
                        viewModel.addUnsavedNotes(noteList)
                        
                        onDismiss()  // Dismiss the view after completion
                    }
                }
            } catch {
                await MainActor.run {
                    DispatchQueue.main.async {
                        isLoading = false
                        errorMessage = error.localizedDescription
                        print("Error in processReflection: \(error)")
                    }
                }
            }
        }
    }
    
    
    //    public func requestSpeechAuthorization() {
    //        SFSpeechRecognizer.requestAuthorization { authStatus in
    //            switch authStatus {
    //            case .authorized:
    //                print("Speech recognition authorized")
    //            case .denied:
    //                print("Speech recognition denied")
    //            case .restricted:
    //                print("Speech recognition restricted")
    //            case .notDetermined:
    //                print("Speech recognition not determined")
    //            @unknown default:
    //                print("Unknown status")
    //            }
    //        }
    //    }
    
    private func datePickerView() -> some View {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }
}




