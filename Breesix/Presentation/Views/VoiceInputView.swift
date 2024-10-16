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
    @State private var isRecord: Bool = false
    @State private var isPaused: Bool = false
    @State private var showAlert: Bool = false
    @Binding var isAllStudentsFilled: Bool
    @FocusState private var isTextEditorFocused: Bool
    @State private var showProTips: Bool = true
    let selectedDate: Date
    var onDismiss: () -> Void
    
    private let ttProcessor = OpenAIService(apiToken: "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")
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(red: 0.92, green: 0.96, blue: 0.96))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(alignment: .center) {
                Text("[General Activity]")
                    .font(.title)
                    .bold()
                
                
                DatePickerView(selectedDate: $sumaryTabViewModel.selectedDate)
                    .disabled(isRecord)
                
                ZStack {
                    TextEditor(text: $reflection)
                        .disabled(isRecord)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scrollContentBackground(.hidden)
                        .lineSpacing(10)
                        .multilineTextAlignment(.leading)
                        .cornerRadius(10)
                        .focused($isTextEditorFocused)
                }
                
                if showProTips {
                    ProTipsCard()
                }
                
                Spacer()
                
                if inputType == .speech {
                    ZStack(alignment: .bottom) {
                        HStack(alignment: .center, spacing: 20) {
                            
                            Button(action: {
                                self.speechRecognizer.stopTranscribing()
                                showAlert = true
                            }) {
                                Image("cancel-mic-button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60)
                            }
                            
                            
                            if !isRecord {
                               
                                Button(action: {
                                    isRecord = true
                                    isPaused = false
                                    self.speechRecognizer.startTranscribing()
                                }) {
                                    Image("play-mic-button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80)
                                }
                            } else {
                                // If paused, show play button
                                if isPaused {
                                    Button(action: {
                                        isPaused = false
                                        self.speechRecognizer.resumeTranscribing()
                                    }) {
                                        Image("play-mic-button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80)
                                    }
                                } else {
                                    // If not paused, show save button
                                    Button(action: {
                                        isRecord = false
                                        self.speechRecognizer.stopTranscribing()
                                        self.reflection = self.speechRecognizer.transcript
                                        self.processReflectionActivity()
                                    }) {
                                        Image("save-mic-button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80)
                                    }
                                    .disabled(isLoading)
                                    
                                   
                                    if isLoading {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 80, height: 80)
                                            .overlay {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                                    .scaleEffect(1.5)
                                            }
                                    } else if let error = errorMessage {
                                        Text(error)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                            
                            
                            Button(action: {
                                if isRecord {
                                    isPaused.toggle()
                                    if isPaused {
                                        self.speechRecognizer.pauseTranscribing()
                                    } else {
                                        self.speechRecognizer.resumeTranscribing()
                                    }
                                }
                            }) {
                                Image("pause-mic-button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60)
                            }
                        }
                        .padding(10)
                    }
                }
            }
            .padding()
        }
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
        .padding(.vertical, 20)
        .onAppear {
            resetIsFilledTodayIfNeeded()
            requestSpeechAuthorization()
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



