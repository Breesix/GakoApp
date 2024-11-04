//
//  TextInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//
import SwiftUI

import SwiftUI

struct TextInputView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = TextInputViewModel()
    @State private var showAlert: Bool = false
    @State private var showEmptyReflectionAlert: Bool = false
    @State private var showProTips: Bool = true
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

            VStack(spacing: 16) {
                datePickerView()
                    .padding(.top, 24)
                    .disabled(viewModel.isLoading)
                
                if showProTips {
                                        GuidingQuestions()
                                            .padding(.top, 12)
                                        Spacer()
                                        TipsCard()
                                    }

                ZStack {
                    TextEditor(text: $viewModel.reflection)
                        .foregroundStyle(.labelPrimaryBlack)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 170)
                        .scrollContentBackground(.hidden)
                        .lineSpacing(5)
                        .multilineTextAlignment(.leading)
                        .cornerRadius(10)
                        .focused($isTextEditorFocused)
                        .disabled(viewModel.isLoading)
                        .opacity(viewModel.isLoading ? 0.5 : 1)
                }
                .onChange(of: viewModel.reflection) { newValue in
                    viewModel.reflection = newValue
                }

                Spacer()
                
                buttonSection()
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 28)
            .alert("Curhatan Kosong", isPresented: $showEmptyReflectionAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Mohon isi curhatan sebelum melanjutkan.")
            }
            .alert("Batalkan Dokumentasi?", isPresented: $showAlert) {
                Button("Batalkan", role: .destructive) {
                    dismiss() // Use dismiss() directly
                }
                Button("Lanjutkan", role: .cancel) {}
            } message: {
                Text("Semua teks yang baru saja Anda masukkan akan terhapus secara permanen.")
            }
        }
        .background(.white)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .hideTabBar()

    }

    private func buttonSection() -> some View {
        VStack(spacing: 16) {
            Button(action: {
                if viewModel.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    showEmptyReflectionAlert = true
                } else {
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
                Text("Simpan")
                    .font(.body)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(viewModel.isLoading)

            Button("Batal") {
                showAlert = true
            }
            .padding(.top, 9)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundColor(.red)
            .disabled(viewModel.isLoading)
        }
    }

    private func datePickerView() -> some View {
        Button(action: {
            // Implement date picker if needed
        }) {
            HStack {
                Image(systemName: "calendar")
                Text(selectedDate, format: .dateTime.day().month().year())
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }


}

// Preview
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
