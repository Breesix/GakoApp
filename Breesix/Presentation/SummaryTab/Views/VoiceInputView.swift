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
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: StudentTabViewModel
    @ObservedObject var speechRecognizer = SpeechRecognizer()
    
    @StateObject private var sumaryTabViewModel = SummaryTabViewModel()
    
    @State private var isShowingPreview = false
    
    @State private var reflection: String = ""
    @State private var previousText: String = ""
    @State private var editedText: String = ""
    @State private var isFirstTranscript: Bool = true
    
    
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
    
        private let ttProcessor = OpenAIService(apiToken: "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")
        
//        private let ttProcessor = LlamaService(apiKey: "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")

    var body: some View {
        ZStack{
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    isTextEditorFocused = false
                }
            
            VStack(alignment: .center) {
                VStack {
                    datePickerView()
                    if reflection.isEmpty && !isRecording {
                        VStack(alignment: .leading,spacing: 16) {
                            Text("Apa saja kegiatan murid Anda di sekolah hari ini?")
                                .foregroundColor(.gray)
                            
                            
                            Text("Bagaimana murid Anda mengikuti kegiatan pada hari ini?")
                                .foregroundColor(.gray)
                            
                        }
                        .padding()
                    }
                    
                    ZStack {
                        TextEditor(text: $editedText)
                            .foregroundStyle(.labelPrimaryBlack)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollContentBackground(.hidden)
                            .lineSpacing(5)
                            .multilineTextAlignment(.leading)
                            .cornerRadius(10)
                            .focused($isTextEditorFocused)
                            .disabled(isLoading)
                            .opacity(isLoading ? 0.5 : 1)
                    }
                    .onChange(of: editedText) { newValue in
                                        // Update reflection ketika user mengedit teks
                                        reflection = newValue
                        speechRecognizer.previousTranscript = newValue
                                    }

                    Spacer()
                    if !isRecording  {
                        TipsCard()
                            .padding()
                    }
                }
                .opacity(isLoading ? 0.3 : 1)
                
                Spacer()
                
                
                ZStack(alignment: .bottom) {
                    HStack(alignment: .center, spacing: 35) {
                        
                        Button(action: {
                            self.speechRecognizer.stopTranscribing()
                            showAlert = true
                        }) {
                            Image("cancel-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56, height: 56)
                        }
                        
                        
                        Button(action: {
                            if !isRecording {
                                speechRecognizer.previousTranscript = editedText
                                isRecording = true
                                isPaused = false
                                speechRecognizer.startTranscribing()
                            } else {
                                
                                isPaused.toggle()
                                if isPaused {
                                    self.speechRecognizer.pauseTranscribing()
                                } else {
                                    self.speechRecognizer.resumeTranscribing()
                                }
                            }
                        }) {
                            if showProTips {
                                if isLoading {
                                    ZStack {
                                        ZStack {
                                            DotLottieAnimation(fileName: "loading-lottie", config: AnimationConfig(autoplay: true, loop: true))
                                                .view()
                                                .scaleEffect(1.5)
                                                .frame(width: 100, height: 100)
                                            
                                            
                                        }
                                    }
                                    
                                    
                                } else {
                                    if isRecording {
                                        if isPaused {
                                            Image("play-mic-button")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 84, height: 84)
                                            
                                        } else {
                                            DotLottieAnimation(fileName: "record-lottie", config: AnimationConfig(autoplay: true, loop: true))
                                                .view()
                                                .scaleEffect(1.5)
                                                .frame(width: 100, height: 100)
                                        }
                                    } else {
                                        Image("start-mic-button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 84, height: 84)
                                        
                                    }
                                }
                            }
                        }
                        .disabled(isLoading)
                        
                        
                        Button(action: {
                            if isRecording {
                                DispatchQueue.main.async {
                                    isLoading = true
                                    isRecording = false
                                    self.speechRecognizer.stopTranscribing()
                                    self.reflection = self.speechRecognizer.transcript
                                    
                                    
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
                        .disabled(!isRecording || isLoading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 12)
                }
                
            }
            
        }
        
        .padding(.horizontal, 25)
        .padding(.vertical, 40)
        .padding(.top, 35)
        .padding(.bottom, 12)
        .background(.white)
        .hideTabBar()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.all)
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
            if isRecording {
                DispatchQueue.main.async{
                    if let lastWord = newTranscript.components(separatedBy: " ").last {
                        editedText = editedText + " " + lastWord
                    }
                    reflection = editedText
                }
            }
        }
        
        .onAppear {
            requestSpeechAuthorization()
            
        }
        .onChange(of: isTextEditorFocused) { focused in
            withAnimation {
                showProTips = !focused
            }
        }
    }
    
    private func processReflectionActivity() {
        Task {
            do {
                isLoading = true
                errorMessage = nil

                await viewModel.fetchAllStudents()
                if viewModel.students.isEmpty {
                                await MainActor.run {
                                    isLoading = false
                                    
                                }
                                return
                }

                if reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    await MainActor.run {
                        isLoading = false
                        
                    }
                    return
                }
                
                let csvString = try await ttProcessor.processReflection(reflection: reflection, students: viewModel.students)

                let (activityList, noteList) = ReflectionCSVParser.parseActivitiesAndNotes(csvString: csvString, students: viewModel.students, createdAt: selectedDate)

                await MainActor.run {
                    isLoading = false

                    viewModel.addUnsavedActivities(activityList)
                    viewModel.addUnsavedNotes(noteList)
                    viewModel.selectedDate = selectedDate
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
    
    private func clearText() {
        reflection = ""
        previousText = ""
        speechRecognizer.transcript = ""
        isRecording = false
        isPaused = false
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




