//
//  SummaryTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct SummaryTabView: View {
    @StateObject private var viewModel = SummaryTabViewModel()
    @State private var isAddingNewActivity = false
    @ObservedObject var studentTabViewModel: StudentTabViewModel
    @State private var isShowingPreview = false
    @State private var isShowingActivity = false
    @State private var isAllStudentsFilled = true
    @State private var isShowingInputTypeSheet = false
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false
    @State private var navigateToPreview = false
    @State private var searchText = ""
    @State private var showTabBar = true
    @State private var hideTabBar = false

    @EnvironmentObject var tabBarController: TabBarController
    var body: some View {
           NavigationView {
               VStack(spacing: 0) {
                   CustomNavigationBar(title: "Ringkasan") {
                       isShowingInputTypeSheet = true
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
           .navigationBarHidden(true)
           .task {
               await studentTabViewModel.fetchAllStudents()
           }
       }
    
    private var studentsWithSummariesOnSelectedDate: [Student] {
        if searchText.isEmpty {
            return studentTabViewModel.students.filter { student in
                student.summaries.contains { summary in
                    Calendar.current.isDate(summary.createdAt, inSameDayAs: viewModel.selectedDate)
                }
            }
        } else {
            return studentTabViewModel.students.filter { student in
                (student.fullname.lowercased().contains(searchText.lowercased()) ||
                 student.nickname.lowercased().contains(searchText.lowercased())) &&
                student.summaries.contains { summary in
                    Calendar.current.isDate(summary.createdAt, inSameDayAs: viewModel.selectedDate)
                }
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
        VStack(spacing: 12) {
            ForEach(studentsWithSummariesOnSelectedDate) { student in
                NavigationLink(destination: StudentDetailView(student: student, viewModel: studentTabViewModel)) {
                    StudentSummaryCard(student: student, selectedDate: viewModel.selectedDate)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 72)
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
                            .background(.white)
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

