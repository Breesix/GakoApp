//
//  PreviewView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct PreviewView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowingPreview: Bool
    @State private var isSaving = false
    @State private var editingNote: UnsavedNote?
    @State private var isAddingNewNote = false
    @State private var selectedStudent: Student?
    @Binding var isShowingActivity: Bool
    @State private var editingActivity: UnsavedActivity?
    @State private var isAddingNewActivity = false
    @State private var showingSummaryError = false
    @State private var summaryErrorMessage = ""
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    @State private var isShowingDatePicker = false
    @State private var isShowingEditSheet = false
    @State private var activities: [Activity] = []
    @State private var progress: Float = 0.0
    @State private var progressTimer: Timer?
    
    
    init(
        selectedDate: Binding<Date>,
        viewModel: StudentTabViewModel,
        isShowingPreview: Binding<Bool>,
        isShowingActivity: Binding<Bool>
    ) {
        self.viewModel = viewModel
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
        self._isShowingPreview = isShowingPreview
        self._isShowingActivity = isShowingActivity
    }
    
    
    var body: some View {
        ZStack {
            if !isSaving {
                // Main Content
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(viewModel.students) { student in
                            StudentSectionView(
                                student: student,
                                viewModel: viewModel,
                                selectedDate: selectedDate,
                                selectedStudent: $selectedStudent,
                                isAddingNewActivity: $isAddingNewActivity,
                                isAddingNewNote: $isAddingNewNote,
                                onDeleteActivity: { activity in
                                    viewModel.deleteUnsavedActivity(activity)
                                }
                            )
                            .padding(.bottom, 12)
                        }
                        
                        Button {
                            saveActivities()
                        } label: {
                            Text("Simpan")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.labelPrimaryBlack)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.orangeClickAble))
                                .cornerRadius(12)
                        }
                    }
                    
                    .padding(.top, 12)
                    .padding(.horizontal, 16)
                    .background(.bgMain)
                }
                .navigationBarItems(
                    leading: Button {
                        viewModel.clearUnsavedNotes()
                        viewModel.clearUnsavedActivities()
                        isShowingPreview = false
                    } label: {
                        HStack{
                            Image(systemName: "chevron.backward")
                                .foregroundStyle(.buttonLinkOnSheet)
                            Text("Pratinjau")
                                .foregroundStyle(.monochromeBlack)
                        }
                        .font(.title3)
                        .fontWeight(.semibold)
                    },
                    trailing: datePickerView().disabled(true)
                )
            }
            
            
            // Loading Overlay
            if isSaving {
                ZStack {
                    Color.white
                        .opacity(0.9)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image("Expressions")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        Text("Menyimpan Dokumentasi...")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.labelPrimaryBlack)
                        
                        ProgressView(value: progress,total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 200)
                            .tint(Color(.orangeClickAble))
                        
                        Text("Mohon tunggu sebentar")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                            .shadow(radius: 10)
                    )
                    .padding(.horizontal, 40)
                }
            }
        }
        .toolbar(.hidden, for: .bottomBar , .tabBar )
        .hideTabBar()
        .navigationBarBackButtonHidden(true)

        //            .overlay(
        //                Group {
        //                    if isSaving {
        //                        ZStack {
        //                            // Background overlay
        //                            Color.white
        //                                .opacity(0.9)
        //                                .ignoresSafeArea()
        //
        //                            VStack(spacing: 20) {
        //                                // Image Expressions
        //                                Image("Expressions") // Pastikan asset image tersedia
        //                                    .resizable()
        //                                    .scaledToFit()
        //                                    .frame(width: 200, height: 200)
        //
        //                                Text("Menyimpan Dokumentasi...")
        //                                    .font(.title3)
        //                                    .fontWeight(.semibold)
        //                                    .foregroundColor(.labelPrimaryBlack)
        //
        //                                // Progress Bar
        //                                ProgressView()
        //                                    .progressViewStyle(LinearProgressViewStyle())
        //                                    .frame(width: 200)
        //                                    .tint(Color(.orangeClickAble))
        //
        //                                Text("Mohon tunggu sebentar")
        //                                    .font(.subheadline)
        //                                    .foregroundColor(.gray)
        //                            }
        //                            .padding()
        //                            .background(
        //                                RoundedRectangle(cornerRadius: 16)
        //                                    .fill(Color.white)
        //                                    .shadow(radius: 10)
        //                            )
        //                            .padding(.horizontal, 40)
        //                        }
        //                    }
        //
        //                }
        //            )
        
        .background(.bgMain)
        .sheet(isPresented: $isAddingNewActivity) {
            if let student = selectedStudent {
                NewUnsavedActivityView(viewModel: viewModel,
                                       student: student,
                                       selectedDate: selectedDate,
                                       onDismiss: {
                    isAddingNewActivity = false
                })
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
            }
        }
        .sheet(item: $editingNote) { note in
            UnsavedNoteEditView(note: note, onSave: { updatedNote in
                updateNote(updatedNote)
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        
        .sheet(isPresented: $isAddingNewNote) {
            if let student = selectedStudent {
                UnsavedNoteCreateView(student: student, onSave: { newNote in
                    addNewNote(newNote)
                }, selectedDate: selectedDate)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
            } else {
                Text("No student selected. Please try again.")
            }
        }
        .onDisappear {
            progressTimer?.invalidate()
            progressTimer = nil
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func binding(for student: Student) -> [Binding<UnsavedActivity>] {
        viewModel.unsavedActivities
            .filter { $0.studentId == student.id }
            .map { activity in
                let index = viewModel.unsavedActivities.firstIndex { $0.id == activity.id }!
                return $viewModel.unsavedActivities[index]
            }
    }
    
    private func saveActivities() {
        isSaving = true
        progress = 0.0
        
        let duration = Double.random(in: 2...4)
        let stepTime = 0.1 // Update setiap 50ms
        let stepValue = stepTime / duration
        
        // Start progress timer
        progressTimer = Timer.scheduledTimer(withTimeInterval: stepTime, repeats: true) { timer in
            withAnimation {
                if progress < 1.0 {
                    progress = min(progress + Float(stepValue), 1.0)
                }
            }
        }
        
        Task {
            do {
                try await viewModel.saveUnsavedActivities()
                try await viewModel.saveUnsavedNotes()
                try await viewModel.generateAndSaveSummaries(for: viewModel.selectedDate)
                
                // Tunggu hingga minimal duration tercapai
                try await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                
                await MainActor.run {
                    progress = 1.0
                    progressTimer?.invalidate()
                    progressTimer = nil
                    
                   
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isSaving = false
                        isShowingPreview = false
                    }
                }
            } catch {
                await MainActor.run {
                    progressTimer?.invalidate()
                    progressTimer = nil
                    isSaving = false
                    showingSummaryError = true
                    summaryErrorMessage = "Failed to save data or generate summaries: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func deleteUnsavedActivity(_ activity: UnsavedActivity) {
        viewModel.deleteUnsavedActivity(activity)
    }
    
    private func deleteNote(_ note: UnsavedNote) {
        viewModel.deleteUnsavedNote(note)
    }
    
    private func updateNote(_ updatedNote: UnsavedNote) {
        viewModel.updateUnsavedNote(updatedNote)
    }
    
    private func addNewNote(_ newNote: UnsavedNote) {
        viewModel.addUnsavedNote(newNote)
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
            .background(Color(.orangeClickAble))
            .cornerRadius(8)
        }
    }
}





struct UnsavedNoteCreateView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var textNote: String = ""
    let student: Student
    let onSave: (UnsavedNote) -> Void
    let selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tambah Catatan")
                    .foregroundStyle(.labelPrimaryBlack)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.cardFieldBG)
                        .frame(maxWidth: .infinity, maxHeight: 170)
                    
                    if textNote.isEmpty {
                        Text("Tuliskan catatan untuk murid...")
                            .font(.callout)
                            .fontWeight(.regular)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity, maxHeight: 170, alignment: .topLeading)
                            .foregroundColor(.labelDisabled)
                            .cornerRadius(8)
                    }
                    
                    TextEditor(text: $textNote)
                        .foregroundStyle(.labelPrimaryBlack)
                        .font(.callout)
                        .fontWeight(.regular)
                        .padding(.horizontal, 8)
                        .frame(maxWidth: .infinity, maxHeight: 170)
                        .cornerRadius(8)
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
                
                Spacer()
            }
            .padding(.top, 34.5)
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tambah Catatan")
                        .foregroundStyle(.labelPrimaryBlack)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Kembali")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let newNote = UnsavedNote(note: textNote, createdAt: selectedDate, studentId: student.id)
                        onSave(newNote)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 27)
                }
            }
        }
        .onAppear {
            print("NoteCreateView appeared for student: \(student.fullname)")
        }
    }
}

