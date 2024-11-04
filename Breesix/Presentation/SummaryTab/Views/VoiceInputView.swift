//
//  InputVoiceView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

// VoiceInputView.swift

import SwiftUI
import Speech
import DotLottie

struct VoiceInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = VoiceInputViewModel()
    @State private var showAlert: Bool = false
    @State private var showProTips: Bool = true
    @State private var isShowingDatePicker = false
    @State private var tempDate: Date
    @FocusState private var isTextEditorFocused: Bool
    
    @Binding var selectedDate: Date
    var onAddUnsavedActivities: ([UnsavedActivity]) -> Void
    var onAddUnsavedNotes: ([UnsavedNote]) -> Void
    var onDateSelected: (Date) -> Void
    var onDismiss: () -> Void
    var fetchStudents: () async -> [Student]
    
    init(
        selectedDate: Binding<Date>,
        onAddUnsavedActivities: @escaping ([UnsavedActivity]) -> Void,
        onAddUnsavedNotes: @escaping ([UnsavedNote]) -> Void,
        onDateSelected: @escaping (Date) -> Void,
        onDismiss: @escaping () -> Void,
        fetchStudents: @escaping () async -> [Student]
    ) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
        self.onAddUnsavedActivities = onAddUnsavedActivities
        self.onAddUnsavedNotes = onAddUnsavedNotes
        self.onDateSelected = onDateSelected
        self.onDismiss = onDismiss
        self.fetchStudents = fetchStudents
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    isTextEditorFocused = false
                }
            
            VStack(alignment: .center) {
                VStack {
                    datePickerView()
                    
                    if viewModel.reflection.isEmpty && !viewModel.isRecording {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Apa saja kegiatan murid Anda di sekolah hari ini?")
                                .foregroundColor(.gray)
                            Text("Bagaimana murid Anda mengikuti kegiatan pada hari ini?")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    ZStack {
                        TextEditor(text: $viewModel.editedText)
                            .foregroundStyle(.labelPrimaryBlack)
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollContentBackground(.hidden)
                            .lineSpacing(5)
                            .multilineTextAlignment(.leading)
                            .cornerRadius(10)
                            .focused($isTextEditorFocused)
                            .disabled(viewModel.isLoading)
                            .opacity(viewModel.isLoading ? 0.5 : 1)
                    }
                    .onChange(of: viewModel.editedText) { newValue in
                        viewModel.reflection = newValue
                        viewModel.speechRecognizer.previousTranscript = newValue
                    }
                    
                    Spacer()
                    
                    if !viewModel.isRecording {
                        TipsCard()
                            .padding()
                    }
                }
                .opacity(viewModel.isLoading ? 0.3 : 1)
                
                Spacer()
                
                // Recording Controls
                ZStack(alignment: .bottom) {
                    HStack(alignment: .center, spacing: 35) {
                        // Cancel Button
                        Button(action: {
                            viewModel.stopRecording(text: viewModel.reflection)
                            showAlert = true
                        }) {
                            Image("cancel-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 56)
                        }
                        
                        // Record/Pause Button
                        Button(action: {
                            if !viewModel.isRecording {
                                viewModel.startRecording()
                            } else {
                                viewModel.isPaused.toggle()
                                if viewModel.isPaused {
                                    viewModel.pauseRecording()
                                } else {
                                    viewModel.resumeRecording()
                                }
                            }
                        }) {
                            if showProTips {
                                if viewModel.isLoading {
                                    DotLottieAnimation(fileName: "loading-lottie",
                                                     config: AnimationConfig(autoplay: true, loop: true))
                                        .view()
                                        .scaleEffect(1.5)
                                        .frame(width: 100, height: 100)
                                } else {
                                    if viewModel.isRecording {
                                        if viewModel.isPaused {
                                            Image("play-mic-button")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 84)
                                        } else {
                                            DotLottieAnimation(fileName: "record-lottie",
                                                             config: AnimationConfig(autoplay: true, loop: true))
                                                .view()
                                                .scaleEffect(1.5)
                                                .frame(width: 100, height: 100)
                                        }
                                    } else {
                                        Image("start-mic-button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 84)
                                    }
                                }
                            }
                        }
                        .disabled(viewModel.isLoading)
                        
                        // Save Button
                        Button(action: {
                            if viewModel.isRecording {
                                Task {
                                    await viewModel.processReflection(
                                        reflection: viewModel.reflection, fetchStudents: fetchStudents,
                                        onAddUnsavedActivities: onAddUnsavedActivities,
                                        onAddUnsavedNotes: onAddUnsavedNotes,
                                        selectedDate: selectedDate,
                                        onDateSelected: onDateSelected,
                                        onDismiss: onDismiss
                                    )
                                }
                            }
                        }) {
                            Image("save-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                        .disabled(!viewModel.isRecording || viewModel.isLoading)
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
                .onChange(of: tempDate) { newValue in
                    selectedDate = tempDate
                    isShowingDatePicker = false
                }
        }
        .onReceive(viewModel.speechRecognizer.$transcript) { newTranscript in
            if viewModel.isRecording {
                if let lastWord = newTranscript.components(separatedBy: " ").last {
                    viewModel.editedText += " " + lastWord
                }
                viewModel.reflection = viewModel.editedText
            }
        }
        .onAppear {
            viewModel.requestSpeechAuthorization()
        }
        .onChange(of: isTextEditorFocused) { newValue in
            withAnimation {
                showProTips = !isTextEditorFocused
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

#Preview {
    VoiceInputView(
        selectedDate: .constant(.now),
        onAddUnsavedActivities: { _ in },
        onAddUnsavedNotes: { _ in },
        onDateSelected: { _ in },
        onDismiss: {},
        fetchStudents: { return [] }
    )
}
