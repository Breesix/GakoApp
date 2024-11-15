//
//  TextInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct TextInputView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel = TextInputViewModel()
    @State private var showAlert: Bool = false
    @State private var showEmptyReflectionAlert: Bool = false
    @State private var showProTips: Bool = true
    @State private var isShowingDatePicker = false
    @State private var tempDate: Date
    @FocusState private var isTextEditorFocused: Bool
    @State private var currentStep: Int = 1
    @State private var firstColor: Color = .bgSecondary
    @State private var secondColor: Color = .bgSecondary
    @State private var thirdColor: Color = .bgAccent
    
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
        let validDate = DateValidator.isValidDate(selectedDate.wrappedValue)
            ? selectedDate.wrappedValue
            : DateValidator.maximumDate()
        self._tempDate = State(initialValue: validDate)
        
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
            
            VStack(alignment: .center, spacing: 16) {
                if currentStep == 2 {
                    HStack {
                        ProgressTracker(
                            firstColor: firstColor,
                            secondColor: secondColor,
                            thirdColor: thirdColor
                        )
                        Spacer()
                        DatePickerButton(
                            isShowingDatePicker: $isShowingDatePicker,
                            selectedDate: $selectedDate
                        )
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal, 16)
                }
                
                VStack(alignment: .center, spacing: 8) {
                    HStack {
                        Image(systemName: "sparkles")
                        Spacer()
                        Text(currentStep == 1 ? "Rekam dengan Teks" : "Konfirmasi isi Curhatan")
                            .fontWeight(.heavy)
                        Spacer()
                        Image(systemName: "sparkles")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.bgMain)
                .cornerRadius(10)
                .foregroundStyle(.bgSecondary)
                .padding(.horizontal, 16)
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .disabled(viewModel.isLoading)
                
                VStack(alignment: .center, spacing: 0) {
                    textEditorSection()
                    
                    if currentStep == 1 {
                        Spacer()
                        VStack(alignment:.leading, spacing: 12) {
                            GuidingQuestionTag(text: "Apakah aktivitas dijalankan dengan baik?")
                            GuidingQuestionTag(text: "Apakah Murid mengalami kendala?")
                            GuidingQuestionTag(text: "Bagaimana Murid Anda menjalankan aktivitasnya?")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    } else {
                        Spacer()
                        TipsCard()
                            .padding(.vertical, 16)
                    }
                    
                    Divider()
                    navigationButtons()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal, 16)
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
    
    private func navigationButtons() -> some View {
        HStack {
            Button {
                if currentStep == 1 {
                    showAlert = true
                } else {
                    currentStep -= 1
                }
            } label: {
                Text(currentStep == 1 ? "Batal" : "Kembali")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(12)
            }
            
            Button {
                if currentStep == 1 {
                    currentStep += 1
                } else {
                    if viewModel.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        showEmptyReflectionAlert = true
                    } else {
                        Task {
                            await viewModel.processReflection(
                                reflection: viewModel.reflection,
                                fetchStudents: fetchStudents,
                                onAddUnsavedActivities: onAddUnsavedActivities,
                                onAddUnsavedNotes: onAddUnsavedNotes,
                                selectedDate: selectedDate,
                                onDateSelected: onDateSelected,
                                onDismiss: onDismiss
                            )
                        }
                    }
                }
            } label: {
                Text(currentStep == 1 ? "Selesai" : "Lanjutkan")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.orangeClickAble)
                    .cornerRadius(12)
            }
        }
        .font(.body)
        .fontWeight(.semibold)
        .foregroundStyle(.labelPrimaryBlack)
    }
    
    private func updateProgressColors() {
        firstColor = .bgSecondary
        secondColor = .bgSecondary
        thirdColor = .bgAccent
    }
}


private extension TextInputView {
    func textEditorSection() -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(.white)
                .frame(maxWidth: .infinity, maxHeight: 170)
            
            if viewModel.reflection.isEmpty {
                Text("Ceritakan mengenai Murid Anda...")
                    .font(.callout)
                    .fontWeight(.regular)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 9)
                    .frame(maxWidth: .infinity, maxHeight: 230, alignment: .topLeading)
                    .foregroundColor(.labelDisabled)
                    .cornerRadius(8)
            }
            
            TextEditor(text: $viewModel.reflection)
                .font(.callout)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .foregroundStyle(.labelPrimaryBlack)
                .frame(maxWidth: .infinity, maxHeight: 230)
                .cornerRadius(8)
                .focused($isTextEditorFocused)
                .scrollContentBackground(.hidden)
                .disabled(viewModel.isLoading)
                .opacity(viewModel.isLoading ? 0.5 : 1)
        }
        .onAppear { UITextView.appearance().backgroundColor = .clear }
        .onDisappear { UITextView.appearance().backgroundColor = nil }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.monochrome9002, lineWidth: 2)
        )
    }
    
    
    private func datePickerSheet() -> some View {
        NavigationStack {
            DatePicker(
                "Select Date",
                selection: $tempDate,
                in: ...DateValidator.maximumDate(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "id_ID"))
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Pilih Tanggal")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 14)
                        .padding(.horizontal, 12)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingDatePicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding(.top, 14)
                    .padding(.horizontal, 12)
                }
            }
            .onChange(of: tempDate) {
                if DateValidator.isValidDate(tempDate) {
                    selectedDate = tempDate
                    isShowingDatePicker = false
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    TextInputView(
        selectedDate: .constant(.now),
        onAddUnsavedActivities: { _ in },
        onAddUnsavedNotes: { _ in },
        onDateSelected: { _ in },
        onDismiss: {},
        fetchStudents: { return [] }
    )
}
