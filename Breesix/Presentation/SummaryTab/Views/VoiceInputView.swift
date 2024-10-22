//
//  InputVoiceView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//


import SwiftUI
import Speech

struct VoiceInputView: View {
    @ObservedObject var studentListViewModel: StudentTabViewModel
    @StateObject private var sumaryTabViewModel = SummaryTabViewModel()
    @ObservedObject var speechRecognizer = SpeechRecognizer()
    @State private var isShowingPreview = false
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var isRecord: Bool = false
    @State private var isPaused: Bool = false
    @State private var showAlert: Bool = false
    @FocusState private var isTextEditorFocused: Bool
    @State private var showProTips: Bool = true
    @State private var selectedDate: Date = Date()

    var onDismiss: () -> Void
    
    private let reflectionProcessor = OpenAIService(apiToken: "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")
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(Color(red: 0.92, green: 0.96, blue: 0.96))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(alignment: .center) {
                Text("[General Activity]")
                    .font(.title)
                    .bold()
                
            
                datePickerView()
                    
                
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
                
                if !isRecord  {
                    ProTipsCard()
                }
                
                Spacer()
                
               
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
                                    Button(action: {
                                        isRecord = false
                                        self.speechRecognizer.stopTranscribing()
                                        self.reflection = self.speechRecognizer.transcript
                                        processReflectionActivity()
                                    }) {
                                        if isLoading {
                                           
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 80, height: 80)
                                                .overlay {
                                                    ProgressView()
                                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                                        .scaleEffect(1.5)
                                                }
                                        } else {
                                            
                                            Image("save-mic-button")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 80, height: 80)
                                        }
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
            .padding()
        }
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
        .padding(.vertical, 20)
        .onAppear {
            requestSpeechAuthorization()
        }
    }
    
    private func processReflectionActivity() {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                
                await studentListViewModel.fetchAllStudents()
                
                let csvString = try await reflectionProcessor.processReflection(reflection: reflection, students: studentListViewModel.students)
                
                let (activityList, noteList) = ReflectionCSVParser.parseActivitiesAndNotes(csvString: csvString, students: studentListViewModel.students, createdAt: selectedDate)
                
                await MainActor.run {
                    isLoading = false
                    
                    studentListViewModel.addUnsavedActivities(activityList)
                    studentListViewModel.addUnsavedNotes(noteList)
                    studentListViewModel.selectedDate = selectedDate
                    
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
    
    private func datePickerView() -> some View {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }
}




