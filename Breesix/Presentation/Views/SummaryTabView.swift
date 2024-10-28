//
//  SummaryTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct SummaryTabView: View {
    @StateObject private var viewModel = SummaryTabViewModel()
    @ObservedObject var studentListViewModel: StudentListViewModel
    @State private var isShowingPreview = false
    @State private var isShowingActivity = false
    @State private var selectedInputType: InputType = .manual
    @State private var isAllStudentsFilled = true
    @State private var isShowingInputTypeSheet = false
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false
    @State private var navigateToPreview = false
    @State private var searchText = ""
<<<<<<< HEAD:Breesix/Presentation/SummaryTab/Views/SummaryTabView.swift
    @State private var showTabBar = true
    @State private var hideTabBar = false
    @State private var showEmptyStudentsAlert: Bool = false

    @EnvironmentObject var tabBarController: TabBarController
    var body: some View {
           NavigationView {
               VStack(spacing: 0) {
                   CustomNavigationBar(title: "Ringkasan") {
                       if studentTabViewModel.students.isEmpty {
                           showEmptyStudentsAlert = true
                       } else {
                           isShowingInputTypeSheet = true
                       }
                   }
                   DailyDateSlider(selectedDate: $viewModel.selectedDate)
                       .padding(16)
                   Group {
                       if studentsWithSummariesOnSelectedDate.isEmpty {
                           VStack {
                               Spacer()
                               EmptyState(message: "Belum ada catatan di hari ini.")
                               Spacer()
                           }
                       } else {
                           ScrollView {
                                   studentsListView()
                           }
                       }
                   }
               }
               .background(.bgMain)
               .sheet(isPresented: $isShowingInputTypeSheet) {
                   InputTypeSheet(studentListViewModel: studentTabViewModel, onSelect: { selectedInput in
                       switch selectedInput {
                       case .voice:
                           isShowingInputTypeSheet = false
                           isNavigatingToVoiceInput = true
                       case .text:
                           isShowingInputTypeSheet = false
                           isNavigatingToTextInput = true
                       }
                   })
                   .background(.white)
                   .presentationDetents([.medium])
                   .presentationDragIndicator(.visible)
               }
               .background(
                   NavigationLink(
                       destination: PreviewView(
                        selectedDate: $viewModel.selectedDate,
                        viewModel: studentTabViewModel,
                        isShowingPreview: $navigateToPreview,
                        isShowingActivity: .constant(false)
                       ),isActive: $navigateToPreview
                   ) { EmptyView() }
               )
               .background(
                NavigationLink(destination: VoiceInputView(selectedDate: $viewModel.selectedDate, viewModel: studentTabViewModel, onDismiss: {
                       isNavigatingToVoiceInput = false
                       navigateToPreview = true
                   })
                    .background(.white)
                   ,isActive: $isNavigatingToVoiceInput) { EmptyView() }
               )
               .background(
                NavigationLink(destination: TextInputView(selectedDate: $viewModel.selectedDate, studentListViewModel: studentTabViewModel, onDismiss: {
                       isNavigatingToTextInput = false
                       navigateToPreview = true
                   })
                   , isActive: $isNavigatingToTextInput) { EmptyView() }
               )

           }
           .alert("Tidak Ada Data Murid", isPresented: $showEmptyStudentsAlert) {
               Button("OK", role: .cancel) {}
           } message: {
               Text("Anda perlu menambahkan data murid terlebih dahulu sebelum membuat dokumentasi.")
           }
           .navigationBarHidden(true)
           .task {
               await studentTabViewModel.fetchAllStudents()
           }
       }
=======
>>>>>>> main:Breesix/Presentation/Views/SummaryTabView.swift
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    datePickerView()
                    HStack {
                        PlusButton(action: {
                            isShowingInputTypeSheet = true
                        }, imageName: "plus.circle.fill")
                        Spacer()
                    }
                    studentsListView()
                }
                .padding()
            }
            .navigationTitle("Curhat")
            
            .sheet(isPresented: $isShowingInputTypeSheet) {
                InputTypeSheet(studentListViewModel: studentListViewModel, onSelect: { selectedInput in
                    switch selectedInput {
                    case .voice:
                        isShowingInputTypeSheet = false
                        isNavigatingToVoiceInput = true
                    case .text:
                        isShowingInputTypeSheet = false
                        isNavigatingToTextInput = true
                    }
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $navigateToPreview){
                PreviewView(viewModel: studentListViewModel, isShowingPreview: $navigateToPreview, isShowingActivity: Binding.constant(false), selectedDate: viewModel.selectedDate)
                
            }
            .background(
                NavigationLink(destination: VoiceInputView(studentListViewModel: studentListViewModel, onDismiss: {
                    isNavigatingToVoiceInput = false
                    navigateToPreview = true
                }), isActive: $isNavigatingToVoiceInput) { EmptyView() }
            )
            .background(
                NavigationLink(destination: TextInputView(studentListViewModel: studentListViewModel, onDismiss: {
                    isNavigatingToTextInput = false
                    navigateToPreview = true
                }), isActive: $isNavigatingToTextInput) { EmptyView() }
            )
        }
        .task {
            await studentListViewModel.fetchAllStudents()
        }
        .searchable(text: $searchText)
    }
    
    private var filteredStudents: [Student] {
        if searchText.isEmpty {
            return studentListViewModel.students
        } else {
            return studentListViewModel.students.filter { student in
                student.fullname.lowercased().contains(searchText.lowercased()) ||
                student.nickname.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    @ViewBuilder
    private func datePickerView() -> some View {
        DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }
     
    struct InputTypeButton: View {
        let title: String
        let action: () -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .padding()
                Button(action: action) {
                    Text("CURHAT DONG MAH")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(.gray.opacity(0.5))
            .cornerRadius(8)
        }
    }
    
    @ViewBuilder
    private func studentsListView() -> some View {
        ForEach(filteredStudents) { student in
            NavigationLink(destination: StudentDetailView(student: student, viewModel: studentListViewModel)) {
                StudentRowView(student: student, selectedDate: viewModel.selectedDate)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(red: 0.92, green: 0.96, blue: 0.96))
            .cornerRadius(8)
        }
    }
    struct StudentRowView: View {
        let student: Student
        let selectedDate: Date
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(student.fullname)
                    .font(.title)
                
                let dailySummaries = student.summaries.filter {
                    Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
                }
                
                if dailySummaries.isEmpty {
                    Text("Tidak ada rangkuman pada hari ini")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    DailySummariesView(summaries: dailySummaries)
                }
            }
        }
    }
    struct ActivityView: View {
        let activity: Activity
        
        var body: some View {
            VStack(alignment: .leading) {
                
                if let status = activity.isIndependent {
                    HStack {
                        Image(systemName: "figure.walk.motion")
                            .scaledToFit()
                            .foregroundColor(.white)
                        Text(status ? "Mandiri" : "Dibimbing")
                            .font(.footnote)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    
                } else {
                    Text("Tidak ada aktivitas terbaru")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .background(Color.blue)
            .cornerRadius(24)
            .frame(width: 140,height: 5)
            .padding()
            
        }
    }
    struct DailySummariesView: View {
        let summaries: [Summary]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(summaries, id: \.id) { summary in
                    Text(summary.summary)
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(8)
                }
            }
            .padding()

        }
        
    }
    
    enum ActiveSheet: Identifiable {
        case reflection
        case preview
        case mandatory
        case activity
        
        var id: Int {
            hashValue
        }
    }
    
}

enum InputType {
    case speech
    case manual
}
