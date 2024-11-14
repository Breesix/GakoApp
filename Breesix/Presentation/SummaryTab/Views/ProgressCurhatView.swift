//
//  ProgressCurhatView.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//

import SwiftUI
import SwiftData

struct ProgressCurhatView: View {
    @State private var firstColor: Color = .bgAccent
    @State private var secondColor: Color = .bgMain
    @State private var thirdColor: Color = .bgMain
    @State private var isToggleOn = false
    @State private var isShowingDatePicker = false
    @State private var showAlert: Bool = false
    @State private var selectedStudents: Set<Student> = []
    @State private var currentProgress: Int = 1
    @State private var showEmptyStudentsAlert: Bool = false
    @Binding var selectedDate: Date
    
    @State private var isShowingInputTypeSheet = false
    
    @EnvironmentObject var summaryViewModel: SummaryViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    
    @State private var navigateToPreview = false
    
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var studentViewModel: StudentViewModel
    
    var onNavigateToVoiceInput: () -> Void
    var onNavigateToTextInput: () -> Void
    
    private var currentTitle: String {
        switch currentProgress {
        case 1:
            return "Apakah semua Murid hadir?"
        case 2:
            return "Tambahkan aktivitas"
        case 3:
            return "Ceritakan tentang Hari ini"
        default:
            return ""
        }
    }
    
    private var currentSubtitle: String {
        switch currentProgress {
        case 1:
            return "Pilih murid Anda yang hadir untuk mengikuti aktivitas hari ini."
        case 2:
            return "Tambahkan rincian aktivitas murid anda hari ini."
        case 3:
            return "Rekam cerita Anda terkait kegiatan murid Anda pada hari ini sedetail mungkin."
        default:
            return ""
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ProgressTracker(firstColor: firstColor, secondColor: secondColor, thirdColor: thirdColor)
                Spacer()
                DatePickerButton(isShowingDatePicker: $isShowingDatePicker, selectedDate: $selectedDate)
            }
            
            TitleProgressCard(title: currentTitle, subtitle: currentSubtitle)
            
            if currentProgress == 3 {
//                Spacer()
//                Text("saya berada di progress 3. murid yang hadir: ")
//                    .font(.headline)
//                    .foregroundColor(.black)
//                ForEach(Array(selectedStudents), id: \.id) { student in
//                        Text(student.fullname)
//                            .font(.body)
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 12)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//                }
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
                AttendanceToggle(
                    isToggleOn: $isToggleOn,
                    students: studentViewModel.students,
                    selectedStudents: $selectedStudents
                )
                
                StudentGridView(
                    students: studentViewModel.students,
                    selectedStudents: $selectedStudents,
                    onDeleteStudent: { student in
                        await studentViewModel.deleteStudent(student)
                    }
                )
            } else if currentProgress == 2 {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Murid yang Hadir:")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(Array(selectedStudents), id: \.id) { student in
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.gray)
                                Text(student.fullname)
                                    .font(.body)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }

            HStack {
                // Back/Cancel Button
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
                        if !selectedStudents.isEmpty {
                            isShowingInputTypeSheet = true
                        }
                    }
                    
                    if currentProgress == 2 {
                        for student in selectedStudents {
                            print("Selected student fullname: \(student.fullname)")
                        }
                    }
                } label: {
                    Text(currentProgress < 3 ? "Lanjut" : "Mulai Curhat")
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
            Button("Batalkan Dokumentasi", role: .destructive, action: {
                presentationMode.wrappedValue.dismiss()
            })
            Button("Lanjut Dokumentasi", role: .cancel, action: {})
        } message: {
            Text("Semua teks yang baru saja Anda masukkan akan terhapus secara permanen.")
        }
        .padding(.horizontal, 16)
        .background(.white)
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .hideTabBar()
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
