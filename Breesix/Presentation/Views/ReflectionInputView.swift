//
//  ReflectionInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI
import Speech


struct ReflectionInputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @ObservedObject var speechRecognizer = SpeechRecognizer()
    @Binding var isShowingPreview: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var isRecord: Bool = false
    @State private var errorMessage: String?
    var inputType: InputType
    let screenBounds = UIScreen.main.bounds
    
    let selectedDate: Date
    var onDismiss: () -> Void
    
    private let reflectionProcessor = ReflectionProcessor(apiToken: "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")
    
    var body: some View {
        NavigationView {
            
            VStack(alignment: .center) {
                ZStack(alignment: .center) {
                    
                    TextEditor(text: $reflection)
                        .padding()
                        .border(Color.gray, width: 1)
                    
                    if reflection.isEmpty {
                        VStack(alignment:.center) {
                            Text("Please enter your reflection here")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .position(x: screenBounds.width / 2, y: screenBounds.height / 2)
                    }
                    
                    
                    if isLoading {
                        ProgressView()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                    
                    
                    
                }.padding()
                if inputType == .speech {
                    if !isRecord {
                        Button(action: {
                            self.speechRecognizer.startTranscribing()
                            isRecord.toggle()
                        }) {
                            Image("play-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .overlay{
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round))
                                        .foregroundColor(.black)
                                        .shadow(radius: 2)
                                }
                        }
                    } else {
                        Button(action: {
                            self.speechRecognizer.stopTranscribing()
                            self.reflection = self.speechRecognizer.transcript
                            isRecord.toggle()
                        }) {
                            Image("stop-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                                .overlay{
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round))
                                        .foregroundColor(.black)
                                        .shadow(radius: 2)
                                }
                            
                        }
                    }
                }
                
                Button("Next") {
                    processReflection()
                }
                .padding()
                .disabled(reflection.isEmpty || isLoading)
            }
            .navigationTitle("Curhat Manual")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            requestSpeechAuthorization()
        }
        .onReceive(speechRecognizer.$transcript) { newTranscript in
            self.reflection = newTranscript
        }
    }
    
    private func processReflection() {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                
                await viewModel.loadStudents()
                
                let csvString = try await reflectionProcessor.processReflection(reflection: reflection, students: viewModel.students)
                
                let unsavedActivities = CSVParser.parseUnsavedActivities(csvString: csvString, students: viewModel.students, createdAt: selectedDate)
                
                await MainActor.run {
                    isLoading = false
                    viewModel.addUnsavedActivities(unsavedActivities)
                    presentationMode.wrappedValue.dismiss()
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
    func requestSpeechAuthorization() {
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
