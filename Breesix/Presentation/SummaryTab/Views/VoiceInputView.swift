//
//  InputVoiceView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//


import SwiftUI
import Speech
import DotLottie

struct VoiceInputView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @StateObject private var sumaryTabViewModel = SummaryTabViewModel()
    @ObservedObject var speechRecognizer = SpeechRecognizer()
    @State private var isShowingPreview = false
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    @State var isFilledToday: Bool = false
    @State private var isRecording = false
    @State private var isPaused = false
    @State private var isSaving = false
    @State private var isShowingDatePicker = false
    @State private var showAlert: Bool = false
    @FocusState private var isTextEditorFocused: Bool
    @State private var showProTips: Bool = true
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    @State private var showTabBar = false
    
    
    var onDismiss: () -> Void
    init(selectedDate: Binding<Date>, viewModel: StudentTabViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
        
        self.onDismiss = onDismiss
    }
    
    private let reflectionProcessor = OpenAIService(apiToken: "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")
    
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
                Spacer()
                if !isRecording  {
                    TipsCard()
                        .padding()
                }
                
                Spacer()
                
                
                ZStack(alignment: .bottom) {
                    HStack(alignment: .center, spacing: 30) {
                        // Cancel Button
                        Button(action: {
                            self.speechRecognizer.stopTranscribing()
                            showAlert = true
                        }) {
                            Image("cancel-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        
                        // Record/Pause/Play Button
                        Button(action: {
                            if !isRecording {
                                // Start Recording
                                isRecording = true
                                isPaused = false
                                self.speechRecognizer.startTranscribing()
                            } else {
                                // Toggle Pause/Play
                                isPaused.toggle()
                                if isPaused {
                                    self.speechRecognizer.pauseTranscribing()
                                } else {
                                    self.speechRecognizer.resumeTranscribing()
                                }
                            }
                        }) {
                            if isLoading {
                                // Loading indicator
                                DotLottieAnimation(fileName: "loading-lottie", config: AnimationConfig(autoplay: true, loop: true)).view()
                                
                            } else {
                                if isRecording {
                                    if isPaused {
                                        Image("play-mic-button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80)
                                        
                                    } else {
                                        DotLottieAnimation(fileName: "record-lottie", config: AnimationConfig(autoplay: true, loop: true)).view()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                        
                                    }
                                } else {
                                    Image("start-mic-button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80)
                                    
                                }
                            }
                        }
                        .disabled(isLoading) // Disable during loading
                        
                        // Save Button
                        Button(action: {
                            if isRecording {
                                DispatchQueue.main.async {
                                    isLoading = true // Show loading
                                    isRecording = false
                                    self.speechRecognizer.stopTranscribing()
                                    self.reflection = self.speechRecognizer.transcript
                                    
                                    // Process with delay to show loading
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        self.processReflectionActivity()
                                    }
                                }
                            }
                        }) {
                            Image("save-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        .disabled(!isRecording || isLoading) // Disable during loading or when not recording
                    }
                    .padding(10)
                }
                
            }
        }
        .hideTabBar()
        .toolbar(.hidden, for: .tabBar)
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
        .sheet(isPresented: $isShowingDatePicker) {
            DatePicker("Select Date", selection: $tempDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .onChange(of: tempDate) { newDate in
                    selectedDate = newDate
                    isShowingDatePicker = false
                }
        }
        .onReceive(speechRecognizer.$transcript) { newTranscript in
            DispatchQueue.main.async {
                self.reflection = newTranscript
            }
        }
        .onAppear {
            requestSpeechAuthorization()
            
        }
    }
    
    private func processReflectionActivity() {
        Task {
            do {
                // Loading state sudah diset sebelum fungsi ini dipanggil
                await viewModel.fetchAllStudents()
                
                let csvString = try await reflectionProcessor.processReflection(
                    reflection: reflection,
                    students: viewModel.students
                )
                
                let (activityList, noteList) = ReflectionCSVParser.parseActivitiesAndNotes(
                    csvString: csvString,
                    students: viewModel.students,
                    createdAt: selectedDate
                )
                
                await MainActor.run {
                    DispatchQueue.main.async {
                        // Update data
                        viewModel.addUnsavedActivities(activityList)
                        viewModel.addUnsavedNotes(noteList)
                        
                        // Hide loading
                        isLoading = false
                        
                        // Dismiss view
                        onDismiss()
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
        Button(action: {
            isShowingDatePicker = true
        }) {
            HStack {
                Image(systemName: "calendar")
                Text(selectedDate, format: .dateTime.day().month().year())
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.buttonPrimaryLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(.bgMain)
            .cornerRadius(8)
        }
    }
}




