//
//  ProgressCurhatView.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//

import SwiftUI
import SwiftData


import SwiftUI

struct ProgressCurhatView: View {
    @State private var firstColor: Color = .bgAccent
    @State private var secondColor: Color = .bgMain
    @State private var thirdColor: Color = .bgMain
    @State private var isToggleOn = false
    @State private var isShowingDatePicker = false
    @State private var showAlert: Bool = false
    @State private var isShowingInputTypeSheet = false
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false
    @State private var navigateToPreview = false

    @State private var selectedStudents: Set<Student> = []
    @State private var currentProgress: Int = 1
    @State private var showEmptyStudentsAlert: Bool = false
    @Binding var selectedDate: Date
    
    var onNavigateVoiceInput: () -> Void
    var onNavigateTextInput: () -> Void

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var summaryViewModel: SummaryViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    ProgressTracker(firstColor: firstColor, secondColor: secondColor, thirdColor: thirdColor)
                    Spacer()
                    DatePickerButton(isShowingDatePicker: $isShowingDatePicker, selectedDate: $selectedDate)
                }
                TitleProgressCard(title: currentTitle, subtitle: currentSubtitle)

                if currentProgress == 3 {
                    
                    displaySelectedStudents()
                  VStack(alignment:.leading, spacing: 12) {
                    GuidingQuestionTag(text: "Apakah aktivitas dijalankan dengan baik?")
                    GuidingQuestionTag(text: "Apakah Murid mengalami kendala?")
                    GuidingQuestionTag(text: "Bagaimana Murid Anda menjalankan aktivitasnya?")
                }
                Spacer()
                TipsCard()
                    .padding(.vertical, 16)
                Divider()
                } else if currentProgress == 1 {
     
                    AttendanceToggle(isToggleOn: $isToggleOn, students: studentViewModel.students, selectedStudents: $selectedStudents)
                    StudentGridView(students: studentViewModel.students, selectedStudents: $selectedStudents, onDeleteStudent: { student in
                        await studentViewModel.deleteStudent(student)
                    })
                } else if currentProgress == 2 {
                 
                    activityInputs()
                }
                navigationButtons()
            }
            .sheet(isPresented: $isShowingInputTypeSheet) {
                InputTypeView { selectedInput in
                    isShowingInputTypeSheet = false
                    switch selectedInput {
                    case .voice:
                        onNavigateVoiceInput()
                    case .text:
                        onNavigateTextInput()
                    }
                }
                .presentationDetents([.medium])
            }
            .padding(.horizontal, 16)
            .navigationBarHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .hideTabBar()
        }
        .sheet(isPresented: $isShowingInputTypeSheet) {
            InputTypeView(onSelect: { selectedInput in
                isShowingInputTypeSheet = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    switch selectedInput {
                    case .voice:
                        onNavigateToVoiceInput()
                    case .text:
                        onNavigateToTextInput()
                    }
                }
            })
            .background(.white)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("Pilih Murid", isPresented: $showEmptyStudentsAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Silakan pilih minimal satu murid yang hadir.")
        }
        .alert("Batalkan Dokumentasi?", isPresented: $showAlert) {
            Button("Batalkan Dokumentasi", role: .destructive) {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Lanjut Dokumentasi", role: .cancel) {}
        } message: {
            Text("Semua teks yang baru saja Anda masukkan akan terhapus secara permanen.")
        }
        .task {
            await studentViewModel.fetchAllStudents()
        }
    }

    private var currentTitle: String {
        switch currentProgress {
        case 1: return "Apakah semua Murid hadir?"
        case 2: return "Tambahkan aktivitas"
        case 3: return "Ceritakan tentang Hari ini"
        default: return ""
        }
    }

    private var currentSubtitle: String {
        switch currentProgress {
        case 1: return "Pilih murid Anda yang hadir untuk mengikuti aktivitas hari ini."
        case 2: return "Tambahkan rincian aktivitas murid anda hari ini."
        case 3: return "Rekam cerita Anda terkait kegiatan murid Anda pada hari ini sedetail mungkin."
        default: return ""
        }
    }

    private func displaySelectedStudents() -> some View {
        ScrollView {
            VStack {
                Text("Masuk")
            }
        }
    }

    private func activityInputs() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(activityViewModel.unsavedActivities) { activity in
                    ActivityTextField(activity: activity)
                }
                AddButton(action: {
                    if let firstStudent = selectedStudents.first {
                        let newActivity = UnsavedActivity(activity: "", createdAt: selectedDate, status: .tidakMelakukan, studentId: firstStudent.id)
                        activityViewModel.addUnsavedActivity(newActivity)
                    }
                }, backgroundColor: .buttonOncard, title: "Tambah")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }

    private func navigationButtons() -> some View {
        HStack {
            Button {
                if currentProgress > 1 {
                    currentProgress -= 1
                    updateProgressColors()
                } else {
                    showAlert = true
                }
            } label: {
                Text(currentProgress > 1 ? "Kembali" : "Batal")
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(12)
            }

            Button {
                if currentProgress == 1 && selectedStudents.isEmpty {
                    showEmptyStudentsAlert = true
                } else if currentProgress < 3 {
                    currentProgress += 1
                    updateProgressColors()
                } else if currentProgress == 3 {
                    isShowingInputTypeSheet = true
                }
            } label: {
                Text(currentProgress == 3 ? "Mulai Cerita" : "Lanjut")
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
        switch currentProgress {
        case 1:
            firstColor = .bgAccent
            secondColor = .bgMain
            thirdColor = .bgMain
        case 2:
            firstColor = .bgSecondary
            secondColor = .bgAccent
            thirdColor = .bgMain
        case 3:
            firstColor = .bgSecondary
            secondColor = .bgSecondary
            thirdColor = .bgAccent
        default:
            break
        }
    }
}


//#Preview {
//    PreviewHelper.PreviewWrapper {
//        ProgressCurhatView(selectedDate: .constant(.now))
//    }
//}
