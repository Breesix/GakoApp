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
    @StateObject private var viewModel = VoiceInputViewModel()
    @State private var showAlert: Bool = false
    @State private var showProTips: Bool = true
    @State private var isShowingDatePicker = false
    @State private var tempDate: Date
    @State private var currentProgress: Int = 1
    @FocusState private var isTextEditorFocused: Bool
    @State private var showEmptyReflectionAlert: Bool = false

    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var summaryViewModel: SummaryViewModel
    
    @Binding var selectedDate: Date
    var onAddUnsavedActivities: ([UnsavedActivity]) -> Void
    var onAddUnsavedNotes: ([UnsavedNote]) -> Void
    var onDateSelected: (Date) -> Void
    var onDismiss: () -> Void
    var fetchStudents: () async -> [Student]
    let selectedStudents: Set<Student>
    let activities: [String]

    init(
        selectedDate: Binding<Date>,
        onAddUnsavedActivities: @escaping ([UnsavedActivity]) -> Void,
        onAddUnsavedNotes: @escaping ([UnsavedNote]) -> Void,
        onDateSelected: @escaping (Date) -> Void,
        onDismiss: @escaping () -> Void,
        fetchStudents: @escaping () async -> [Student],
        selectedStudents: Set<Student>,
        activities: [String]
    ) {
        self._selectedDate = selectedDate
        let validDate = DateValidator.isValidDate(selectedDate.wrappedValue)
        ? selectedDate.wrappedValue
        : DateValidator.maximumDate()
        self._tempDate = State(initialValue: validDate)
        
        self.onAddUnsavedActivities = onAddUnsavedActivities
        self.onAddUnsavedNotes = onAddUnsavedNotes
        self.onDateSelected = onDateSelected
        self.onDismiss = onDismiss
        self.fetchStudents = fetchStudents
        self.selectedStudents = selectedStudents
        self.activities = activities
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
                    TitleProgressCard(title: currentTitle, subtitle: currentSubtitle)
                    ZStack {
                        TextEditor(text: $viewModel.editedText)
                            .foregroundStyle(.labelPrimaryBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 228)
                            .scrollContentBackground(.hidden)
                            .lineSpacing(5)
                            .multilineTextAlignment(.leading)
                            .cornerRadius(10)
                            .focused($isTextEditorFocused)
                            .disabled(viewModel.isLoading || (viewModel.isRecording && !viewModel.isPaused))
                            .opacity(viewModel.isLoading ? 0.5 : 1)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        viewModel.isPaused ? Color.black : Color.clear,
                                        lineWidth: 1
                                    )
                                                                )
                    }
                    .onChange(of: viewModel.editedText) { 
                        studentViewModel.reflection = viewModel.editedText
                        viewModel.speechRecognizer.previousTranscript = viewModel.editedText
                    }
                    
                    Spacer()
                    if !isTextEditorFocused {
                        VStack(alignment:.leading, spacing: 12) {
                            GuidingQuestionTag(text: "Apakah aktivitas dijalankan dengan baik?")
                            GuidingQuestionTag(text: "Apakah Murid mengalami kendala?")
                            GuidingQuestionTag(text: "Bagaimana Murid Anda menjalankan aktivitasnya?")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .opacity(viewModel.isLoading ? 0.3 : 1)
                
                Spacer()

                ZStack(alignment: .bottom) {
                    VStack(alignment: .center){
                        if !isTextEditorFocused {
                        if viewModel.isRecording && !viewModel.isPaused {
                            Text("Tekan \(Image(systemName: "pause.circle.fill")) untuk edit teks")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.bgAccent)
                        } else if !viewModel.isRecording && !viewModel.isPaused{
                            Text("Tekan \(Image(systemName: "mic")) untuk memulai berbicara")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.bgAccent)
                        }
                        else {
                            Text("Tekan \(Image(systemName: "play.fill")) untuk lanjut merekam")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.bgAccent)
                        }
                    }
                        HStack {
                            Button(action: {
                                viewModel.stopRecording(text: studentViewModel.reflection)
                                showAlert = true
                            }) {
                                Text("Batal")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.destructiveOnCardLabel)
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 30.25)
                                    .background(Color.destructiveOnCard)
                                    .cornerRadius(8)
                            }
                            Spacer()
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
                                        if viewModel.isRecording {
                                            if viewModel.isPaused {
                                                PlayButtonVoice()
                                            } else {
                                                PauseButtonVoice()
                                            }
                                        } else {
                                            StartButtonVoice()
                                        }
                            
                            }
                            .disabled(viewModel.isLoading)
                            
                            Spacer()
                            
                            if viewModel.isRecording {
                                Button(action: {
                                    if studentViewModel.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        showEmptyReflectionAlert = true
                                    } else {
                                        viewModel.stopRecording(text: studentViewModel.reflection)
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    Text("Selesai")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 22.75)
                                        .background(Color.orangeClickAble)
                                        .cornerRadius(8)
                                }
                                .disabled(!viewModel.isRecording || viewModel.isLoading)
                            } else {
                                Color.clear
                                    .frame(width: 97, height: 34)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .safeAreaPadding(16)
        .background(.white)
        .hideTabBar()
        .toolbar(.hidden, for: .tabBar)
        .navigationBarBackButtonHidden(true)
        .alert("Curhatan Kosong", isPresented: $showEmptyReflectionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Mohon isi curhatan sebelum melanjutkan.")
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Batalkan Dokumentasi?"),
                message: Text("Semua teks yang anda masukkan akan dihapus secara permanen"),
                primaryButton: .destructive(Text("Ya")) {
                    studentViewModel.reflection.removeAll()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Tidak"))
            )
        }
        .sheet(isPresented: $isShowingDatePicker) {
            datePickerSheet()
        }
        .onReceive(viewModel.speechRecognizer.$transcript) { newTranscript in
            if viewModel.isRecording {
                if let lastWord = newTranscript.components(separatedBy: " ").last {
                    viewModel.editedText += " " + lastWord
                }
                studentViewModel.reflection = viewModel.editedText
            }
        }
        .onAppear {
            viewModel.requestSpeechAuthorization()
        }
        .onChange(of: viewModel.editedText) {             studentViewModel.reflection = viewModel.editedText
            viewModel.speechRecognizer.previousTranscript = viewModel.editedText
        }
        .onChange(of: isTextEditorFocused) {
            withAnimation {
                showProTips = !isTextEditorFocused
            }
        }
        .onChange(of: viewModel.isRecording) {
            if viewModel.isRecording {
                currentProgress = 2
            } else {
                currentProgress = 1
            }
        }
        .onChange(of: viewModel.isPaused) {
            if viewModel.isPaused {
                currentProgress = 3
            } else if viewModel.isRecording {
                currentProgress = 2
            }
        }
    }
    
    private var currentTitle: String {
        switch currentProgress {
        case 1: return "Rekam dengan Suara"
        case 2: return "Merekam..."
        case 3: return "Edit Rekaman"
        default: return ""
        }
    }

    private var currentSubtitle: String {
        switch currentProgress {
        case 1: return "Tekan untuk memulai berbicara"
        default: return ""
        }
    }
    
    private func datePickerView() -> some View {
        Button(action: {
            if !viewModel.isLoading {
                isShowingDatePicker = true
            }
        }) {
            HStack {
                Image(systemName: "calendar")
                Text(selectedDate, format: .dateTime.day().month().year())
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(viewModel.isLoading ? .labelTertiary : .buttonPrimaryLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(.buttonOncard)
            .cornerRadius(8)
        }
        .disabled(viewModel.isLoading)
    }
    
    private func datePickerSheet() -> some View {
        DatePicker(
            "Select Date",
            selection: $tempDate,
            in: ...DateValidator.maximumDate(),
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onChange(of: tempDate) {
            if DateValidator.isValidDate(tempDate) {
                selectedDate = tempDate
                isShowingDatePicker = false
            }
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
        fetchStudents: { return [] },
        selectedStudents: Set<Student>(),
        activities: [] 
    )
}
