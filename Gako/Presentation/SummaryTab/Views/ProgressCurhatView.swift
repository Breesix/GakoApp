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
    @State private var isShowingInputTypeSheet = false
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false
    @State private var navigateToPreview = false

    @State private var showManageActivity: Bool = false
    @State private var activityText: String = ""
    @State private var currentProgress: Int = 1
    @State private var editingActivity: (index: Int, text: String)? = nil
    @State private var showEmptyStudentsAlert: Bool = false
    @State private var showEmptyActivitiesAlert: Bool = false
    @State private var showDeleteAlert = false
    @State private var activityToDelete: Int?

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
     
                    AttendanceToggle(isToggleOn: $isToggleOn, students: studentViewModel.students)
                    StudentGridView(students: studentViewModel.students,  onDeleteStudent: { student in
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
        .alert("Pilih Murid", isPresented: $showEmptyStudentsAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Silakan pilih minimal satu murid yang hadir.")
        }
        .alert("Batalkan Dokumentasi?", isPresented: $showAlert) {
            Button("Batalkan Dokumentasi", role: .destructive) {
                studentViewModel.activities.removeAll()
                studentViewModel.selectedStudents.removeAll()
                presentationMode.wrappedValue.dismiss()
            }
            Button("Lanjut Dokumentasi", role: .cancel) {}
        } message: {
            Text("Semua teks yang baru saja Anda masukkan akan terhapus secara permanen.")
        }
        .alert("Tambah Aktivitas", isPresented: $showEmptyActivitiesAlert) {
            Button("OK", role: .cancel, action: {})
        } message: {
            Text("Silakan tambah minimal satu aktivitas.")
        }
        .alert("Hapus Aktivitas?", isPresented: $showDeleteAlert) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive) {
                if let index = activityToDelete {
                    studentViewModel.activities.remove(at: index)
                }
            }
        } message: {
            Text("Apakah Anda yakin ingin menghapus aktivitas ini?")
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

    private func activityInputs() -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(studentViewModel.activities.indices, id: \.self) { index in
                    ActivityCard(
                        activity: studentViewModel.activities[index],
                        onTap: {
                            editingActivity = (index, studentViewModel.activities[index])
                            activityText = studentViewModel.activities[index]
                            showManageActivity = true
                        },
                        onDelete: {
                            activityToDelete = index
                            showDeleteAlert = true
                        }
                    )

                }
                
                AddItemButton(
                    onTapAction: {
                        showManageActivity = true
                    },
                    bgColor: .buttonOncard,
                    text: "Tambah"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }

            .sheet(isPresented: $showManageActivity) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(editingActivity == nil ? "Tambah Aktivitas" : "Edit Aktivitas")
                            .foregroundStyle(.labelPrimaryBlack)
                            .font(.callout)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ZStack(alignment: .leading) {
                                if activityText.isEmpty {
                                    Text("Tuliskan aktivitas murid...")
                                        .foregroundStyle(.labelTertiary)
                                        .font(.body)
                                        .fontWeight(.regular)
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 9)
                                }
                                
                                TextField("", text: $activityText)
                                    .foregroundStyle(.labelPrimaryBlack)
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .padding(.horizontal, 11)
                                    .padding(.vertical, 9)
                            }
                            .background(.cardFieldBG)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.monochrome50, lineWidth: 0.5)
                            )
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 34.5)
                    .padding(.horizontal, 16)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text(editingActivity == nil ? "Tambah Aktivitas" : "Edit Aktivitas")
                                .foregroundStyle(.labelPrimaryBlack)
                                .font(.body)
                                .fontWeight(.semibold)
                                .padding(.top, 27)
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                showManageActivity = false
                                editingActivity = nil
                                activityText = ""
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
                                if !activityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    if let editing = editingActivity {
                                        studentViewModel.activities[editing.index] = activityText
                                    } else {
                                        studentViewModel.activities.append(activityText)
                                    }
                                    activityText = ""
                                    editingActivity = nil
                                    showManageActivity = false
                                }
                            }) {
                                Text("Simpan")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.top, 27)
                        }
                    }
                }
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
                if currentProgress == 1 && studentViewModel.selectedStudents.isEmpty {
                    showEmptyStudentsAlert = true
                } else if currentProgress == 2 && studentViewModel.activities.isEmpty {
                    showEmptyActivitiesAlert = true
                } else if currentProgress < 3 {
                    currentProgress += 1
                    updateProgressColors()
                } else if currentProgress == 3 {
                    isShowingInputTypeSheet = true
                    print(studentViewModel.activities)
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

struct ActivityCard: View {
    let activity: String
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Text(activity)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.cardFieldBG)
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}


//#Preview {
//    PreviewHelper.PreviewWrapper {
//        ProgressCurhatView(selectedDate: .constant(.now))
//    }
//}
