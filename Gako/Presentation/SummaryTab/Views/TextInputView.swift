//
//  TextInputView.swift
//  GAKO
//
//  Created by Rangga Biner on 15/10/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: View to receive input in form of text
//

import SwiftUI

struct TextInputView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var summaryViewModel: SummaryViewModel
    @StateObject private var viewModel = TextInputViewModel()
    
    @State private var currentProgress: Int = 1
    @State private var showAlert: Bool = false
    @State private var showEmptyReflectionAlert: Bool = false
    @State private var showProTips: Bool = true
    @State private var isShowingDatePicker = false
    @State private var tempDate: Date
    @FocusState private var isTextEditorFocused: Bool
    @State private var firstColor: Color = .bgSecondary
    @State private var secondColor: Color = .bgSecondary
    @State private var thirdColor: Color = .bgAccent
    
    @Binding var selectedDate: Date
    var onAddUnsavedActivities: ([UnsavedActivity]) -> Void
    var onAddUnsavedNotes: ([UnsavedNote]) -> Void
    var onDateSelected: (Date) -> Void
    let selectedStudents: Set<Student>
    let activities: [String]
    var onDismiss: () -> Void

    init(
        selectedDate: Binding<Date>,
        onAddUnsavedActivities: @escaping ([UnsavedActivity]) -> Void,
        onAddUnsavedNotes: @escaping ([UnsavedNote]) -> Void,
        onDateSelected: @escaping (Date) -> Void,
        selectedStudents: Set<Student>,
        activities: [String],
        onDismiss: @escaping () -> Void
    ) {
        self._selectedDate = selectedDate
        let validDate = DateValidator.isValidDate(selectedDate.wrappedValue) ?
            selectedDate.wrappedValue :
            DateValidator.maximumDate()
        self._tempDate = State(initialValue: validDate)
        self.onAddUnsavedActivities = onAddUnsavedActivities
        self.onAddUnsavedNotes = onAddUnsavedNotes
        self.onDateSelected = onDateSelected
        self.selectedStudents = selectedStudents
        self.activities = activities
        self.onDismiss = onDismiss
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
                
                VStack(alignment: .center, spacing: 8) {
                    TitleProgressCard(title: currentTitle, subtitle: currentSubtitle)
                    
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
                        Spacer()
                        VStack(alignment:.leading, spacing: 12) {
                            GuidingQuestionTag(text: "Apakah aktivitas dijalankan dengan baik?")
                            GuidingQuestionTag(text: "Apakah Murid mengalami kendala?")
                            GuidingQuestionTag(text: "Bagaimana Murid Anda menjalankan aktivitasnya?")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    
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
                    studentViewModel.activities.removeAll()
                    studentViewModel.selectedStudents.removeAll()
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
                    showAlert = true
            } label: {
                Text("Batal")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(12)
            }
            
            Button {
                if viewModel.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    showEmptyReflectionAlert = true
                } else {
                    Task {
                        await viewModel.processReflection(
                            reflection: viewModel.reflection,
                            selectedStudents: selectedStudents,
                            activities: activities,
                            onAddUnsavedActivities: onAddUnsavedActivities,
                            onAddUnsavedNotes: onAddUnsavedNotes,
                            selectedDate: selectedDate,
                            onDateSelected: onDateSelected,
                            onDismiss: onDismiss
                        )
                    }
                    
                }
            } label: {
                Text("Selesai")
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
    
    private var currentTitle: String {
        switch currentProgress {
        case 1: return "Rekam dengan Teks"
        default: return ""
        }
    }

    private var currentSubtitle: String {
        switch currentProgress {
        default: return ""
        }
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
    
    
    func buttonSection() -> some View {
        VStack(spacing: 16) {
            Button(action: {
                if viewModel.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    showEmptyReflectionAlert = true
                } else {
                    Task {
                        await viewModel.processReflection(
                            reflection: viewModel.reflection,
                            selectedStudents: selectedStudents, // Add this
                            activities: activities, // Add this
                            onAddUnsavedActivities: { activities in
                                activityViewModel.addUnsavedActivities(activities)
                            },
                            onAddUnsavedNotes: { notes in
                                noteViewModel.addUnsavedNotes(notes)
                            },
                            selectedDate: summaryViewModel.selectedDate,
                            onDateSelected: { date in
                                summaryViewModel.selectedDate = date
                            },
                            onDismiss: onDismiss
                        )
                    }
                }
            }) {
                if viewModel.isLoading {
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
            .disabled(viewModel.isLoading)
            
            Button("Batal") {
                showAlert = true
            }
            .padding(.top, 9)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(viewModel.isLoading ? .labelTertiary : .destructiveOnCardLabel)
            .disabled(viewModel.isLoading)
        }
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
                    summaryViewModel.selectedDate = tempDate
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
        selectedStudents: Set<Student>(), 
        activities: [],
        onDismiss: {}
    )
}

