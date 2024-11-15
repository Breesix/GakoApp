//
//  TextInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct TextInputView: View {
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var summaryViewModel: SummaryViewModel
    @StateObject private var viewModel = TextInputViewModel()
    @State private var showAlert: Bool = false
    @State private var showEmptyReflectionAlert: Bool = false
    @State private var showProTips: Bool = true
    @State private var isShowingDatePicker = false
    @State private var tempDate: Date
    @FocusState private var isTextEditorFocused: Bool
    var onDismiss: () -> Void
    let selectedStudents: Set<Student>
    let activities: [String]

    init(
        selectedDate: Binding<Date>,
        selectedStudents: Set<Student>,
        activities: [String],
        onDismiss: @escaping () -> Void
    ) {
        let validDate = DateValidator.isValidDate(selectedDate.wrappedValue) ?
            selectedDate.wrappedValue :
            DateValidator.maximumDate()
        self._tempDate = State(initialValue: validDate)
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
            
            VStack(spacing: 16) {
                DatePickerButton(
                    isShowingDatePicker: $isShowingDatePicker,
                    selectedDate: $summaryViewModel.selectedDate
                )
                .padding(.top, 24)
                .opacity(viewModel.isLoading ? 0.5 : 1)
                .disabled(viewModel.isLoading)
                
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
                            fetchStudents: {
                                await studentViewModel.fetchAllStudents()
                                return studentViewModel.students
                            },
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
        selectedStudents: Set<Student>(), // Add empty set for preview
        activities: [], // Add empty array for preview
        onDismiss: {}
    )
}

