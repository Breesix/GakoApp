//
//  TextInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct TextInputView: View {
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
    @State private var showEmptyReflectionAlert: Bool = false
    @State private var showTabBar = false
    
    var onAddUnsavedActivities: ([UnsavedActivity]) -> Void
    var onAddUnsavedNotes: ([UnsavedNote]) -> Void
    var onDateSelected: (Date) -> Void
    var onDismiss: () -> Void
    var fetchStudents: () async -> [Student]
    
    private let ttProcessor = OpenAIService(apiToken: "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")
    
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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                 to: nil,
                                                 from: nil,
                                                 for: nil)
                    isTextEditorFocused = false
                }
            
            VStack(spacing: 16) {
                datePickerView()
                    .padding(.top, 24)
                    .disabled(isLoading)
                
                VStack(spacing: 0) {
                    textEditorSection()
                    
                    if showProTips {
                        GuidingQuestions()
                            .padding(.top, 12)
                        Spacer()
                        TipsCard()
                    }
                    
                    Spacer()
                    buttonSection()
                        .padding(.bottom, showProTips ? 24 : 0)
                    
                    if !showProTips {
                        Spacer()
                    }
                }
                .padding(.horizontal, 28)
            }
        }
        .background(.white)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .hideTabBar()
        .alert("Batalkan Dokumentasi?", isPresented: $showAlert) {
                Button("Batalkan Dokumentasi", role: .destructive, action: {
                    presentationMode.wrappedValue.dismiss()
                })
                Button("Lanjut Dokumentasi", role: .cancel, action: {})
        } message: {
            Text("Semua teks yang baru saja Anda masukkan akan terhapus secara permanen.")
        }
        .alert("Curhatan Kosong", isPresented: $showEmptyReflectionAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Mohon isi curhatan sebelum melanjutkan.")
        }
        .sheet(isPresented: $isShowingDatePicker) {
            datePickerSheet()
        }
        .onChange(of: isTextEditorFocused) {
            withAnimation {
                showProTips = !isTextEditorFocused
            }
        }
    }
    
    private func processReflectionActivity() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                     to: nil,
                                     from: nil,
                                     for: nil)
        isTextEditorFocused = false
        
        Task {
            do {
                isLoading = true
                errorMessage = nil
                
                let students = await fetchStudents()
                
                
                if reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    await MainActor.run {
                        isLoading = false
                        showEmptyReflectionAlert = true
                    }
                    return
                }
                
                let csvString = try await ttProcessor.processReflection(
                    reflection: reflection,
                    students: students
                )
                
                let (activityList, noteList) = ReflectionCSVParser.parseActivitiesAndNotes(
                    csvString: csvString,
                    students: students,
                    createdAt: selectedDate
                )
                
                await MainActor.run {
                    isLoading = false
                    onAddUnsavedActivities(activityList)
                    onAddUnsavedNotes(noteList)
                    onDateSelected(selectedDate)
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
        Button(action: { isShowingDatePicker = true }) {
            HStack {
                Image(systemName: "calendar")
                Text(selectedDate, format: .dateTime.day().month().year())
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(isLoading ? .labelTertiary : .buttonPrimaryLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(.buttonOncard)
            .cornerRadius(8)
        }
    }
}

private extension TextInputView {
    func textEditorSection() -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .frame(maxWidth: .infinity, maxHeight: 170)
            
            if reflection.isEmpty {
                Text("Ceritakan mengenai Murid Anda...")
                    .font(.callout)
                    .fontWeight(.regular)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity, maxHeight: 230, alignment: .topLeading)
                    .foregroundColor(.labelDisabled)
                    .cornerRadius(8)
            }
            
            TextEditor(text: $reflection)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .foregroundStyle(.labelPrimaryBlack)
                .frame(maxWidth: .infinity, maxHeight: 230)
                .cornerRadius(8)
                .focused($isTextEditorFocused)
                .scrollContentBackground(.hidden)
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
        }
        .onAppear { UITextView.appearance().backgroundColor = .clear }
        .onDisappear { UITextView.appearance().backgroundColor = nil }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.monochrome9002, lineWidth: 2)
        )
    }
    
    func buttonSection() -> some View {
        VStack(spacing: 16) {
            Button(action: processReflectionActivity) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(.buttonLinkOnSheet)
                        .cornerRadius(12)
                } else {
                    Text("Lanjutkan")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(.buttonLinkOnSheet)
                        .foregroundStyle(.buttonPrimaryLabel)
                        .cornerRadius(12)
                }
            }
            .disabled(isLoading)
            
            Button("Batal") {
                showAlert = true
            }
            .padding(.top, 9)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(isLoading ? .labelTertiary : .destructive)
            .disabled(isLoading)
        }
    }
    
    func datePickerSheet() -> some View {
        DatePicker("Select Date", selection: $tempDate, displayedComponents: .date)
            .datePickerStyle(.graphical)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .onChange(of: tempDate) {
                selectedDate = tempDate
                isShowingDatePicker = false
            }
    }
}
