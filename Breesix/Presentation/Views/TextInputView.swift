//
//  TextInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct TextInputView: View {
    @StateObject private var summaryTabViewModel = SummaryTabViewModel()
    @ObservedObject var studentListViewModel: StudentListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showAlert: Bool = false
    @State private var showProTips: Bool = true
    @FocusState private var isTextEditorFocused: Bool

    // New state variables for navigation and selected date
    @State private var navigateToPreview = false
    @State private var selectedDate: Date = Date() // Default to current date

    // Binding for isNavigatingToTextInput
    @Binding var isNavigatingToTextInput: Bool

    private let ttProcessor = OpenAIService(apiToken: "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")

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            
            VStack {
                Text("Curhat dengan ketikan")
                    .font(.title3)
                    .fontWeight(.semibold)
                datePickerView()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 2)
                        .frame(maxWidth: .infinity, maxHeight: 250)

                    TextEditor(text: $reflection)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(10)
                        .focused($isTextEditorFocused)
                }
                .padding(.bottom, 16)
                
                Button {
                    processReflectionActivity()
                } label: {
                    Text("Submit")
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                if showProTips {
                    ProTipsCard()
                }
                
                Spacer()
                
                Button {
                    showAlert = true
                } label: {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Batalkan")
                    }
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
        }
        .safeAreaPadding()
//        NavigationLink(
//            destination: PreviewView(viewModel: studentListViewModel, isShowingPreview: $navigateToPreview, isShowingActivity: Binding.constant(false), selectedDate: selectedDate),
//            isActive: $navigateToPreview
//        ) {
//            EmptyView()
//        }
        .sheet(isPresented: $navigateToPreview) {
            PreviewView(viewModel: studentListViewModel, isShowingPreview: $navigateToPreview, isShowingActivity: Binding.constant(false), selectedDate: selectedDate)
        }
         
        .onAppear {
            isNavigatingToTextInput = false
        }
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
        .onTapGesture {
            isTextEditorFocused = false
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

                let (activityList, noteList) = TTCSVParser.parseActivitiesAndNotes(csvString: csvString, students: studentListViewModel.students, createdAt: selectedDate)

                await MainActor.run {
                    isLoading = false
                    studentListViewModel.addUnsavedActivities(activityList)
                    studentListViewModel.addUnsavedNotes(noteList)
                    navigateToPreview = true  // pastikan ini dilakukan setelah semua data tersedia
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
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }

}
