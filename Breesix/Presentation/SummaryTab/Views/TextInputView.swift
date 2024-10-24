//
//  TextInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct TextInputView: View {
    @StateObject private var summaryTabViewModel = SummaryTabViewModel()
    @ObservedObject var studentListViewModel: StudentTabViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var showProTips: Bool = true
    @FocusState private var isTextEditorFocused: Bool
    @Binding var selectedDate: Date
    @State private var isShowingDatePicker = false
    @State private var tempDate: Date
    var onDismiss: () -> Void

    init(selectedDate: Binding<Date>, studentListViewModel: StudentTabViewModel, onDismiss: @escaping () -> Void) {
        self.studentListViewModel = studentListViewModel
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)

        self.onDismiss = onDismiss
    }
    
    private let ttProcessor = OpenAIService(apiToken: "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")

    var body: some View {
        ZStack{
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    isTextEditorFocused = false
                }
            VStack {
                datePickerView()
                    .padding(.bottom, 16)
                    .padding(.top, 36)
                VStack{
                    ZStack (alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.cardFieldBG)
                            .frame(maxWidth: .infinity, maxHeight: 170)
                        
                        if reflection.isEmpty {
                            Text("Ceritakan mengenai Murid Anda...")
                                .font(.callout)
                                .fontWeight(.regular)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                                .frame(maxWidth: .infinity, maxHeight: 170, alignment: .topLeading)
                                .foregroundColor(.labelDisabled)
                                .cornerRadius(8)
                        }
                        TextEditor(text: $reflection)
                            .font(.callout)
                            .fontWeight(.regular)
                            .padding(.horizontal, 8)
                            .frame(maxWidth: .infinity, maxHeight: 170)
                            .cornerRadius(8)
                            .focused($isTextEditorFocused)
                            .scrollContentBackground(.hidden)
                    }
                    .onAppear() {
                        UITextView.appearance().backgroundColor = .clear
                    }
                    .onDisappear() {
                        UITextView.appearance().backgroundColor = nil
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.monochrome50, lineWidth: 1)
                    )
                    .padding(.bottom, 16)
                    
                    Button {
                        processReflectionActivity()
                    } label: {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(.buttonPrimaryOnBg)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.bottom, 16)
                    }
                    
                    Button("Batal") {
                        showAlert = true
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.destructive)
                }
                .padding(.horizontal, 28)
                Spacer()
                if showProTips {
                    TipsCard()
                        .padding(.horizontal, 40)
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)

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

                await studentListViewModel.fetchAllStudents()

                let csvString = try await ttProcessor.processReflection(reflection: reflection, students: studentListViewModel.students)

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

