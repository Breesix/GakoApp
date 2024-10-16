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
    @State private var isShowingInputSheet = false
    @State private var selectedInputType: InputType = .manual
    @State private var isAllStudentsFilled = true
    @State private var activeSheet: ActiveSheet? = nil
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DatePickerView(selectedDate: $viewModel.selectedDate)
                    
                    HStack(alignment: .center) {
                        
                        NavigationLink(destination: VoiceInputView(
                            viewModel: studentListViewModel,
                            inputType: .speech,
                            isAllStudentsFilled: $isAllStudentsFilled,
                            selectedDate: viewModel.selectedDate,
                            onDismiss: {
                                isShowingPreview = true
                            }).toolbar(.hidden, for: .tabBar)
                        ) {
                                InputTypeButton(title: "Suara", action: {})
                            }
                        
//                        NavigationLink(destination: TextInputView(
//                            viewModel: studentListViewModel,
//                            inputType: .speech,
//                            isAllStudentsFilled: $isAllStudentsFilled,
//                            selectedDate: viewModel.selectedDate,
//                            onDismiss: {
//                                isShowingPreview = true
//                        })) {
//                            InputTypeButton(title: "Suara", action: {})
//                        }
                        
                        
                        
                    }
                    studentsListView()
                }
                .padding()
                .task {
                    await studentListViewModel.fetchAllStudents()
                }
            }
            .navigationTitle("Curhat")
            

            .sheet(isPresented: $isShowingPreview) {
                PreviewView(
                    viewModel: studentListViewModel,
                    isShowingPreview: $isShowingPreview,
                    isShowingActivity: $isShowingActivity,
                    selectedDate: viewModel.selectedDate
                    
                )
            }
            
        }
    }
    
    
    
    struct InputTypeButton: View {
        let title: String
        let action: () -> Void
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .padding()
                
                Text("CURHAT DONG MAH")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .background(.gray.opacity(0.5))
            .cornerRadius(8)
        }
    }
    @ViewBuilder
    private func studentsListView() -> some View {
        ForEach(studentListViewModel.students) { student in
            NavigationLink(destination: StudentDetailView(student: student, viewModel: studentListViewModel)) {
                StudentRowView(student: student, selectedDate: viewModel.selectedDate)
            }
            .padding()
            .background(Color.gray.opacity(0.3))
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
                
                if let latestActivity = student.activities.sorted(by: { $0.createdAt > $1.createdAt }).first {
                    ActivityView(activity: latestActivity)
                }
                
                let dailyNotes = student.notes.filter {
                    Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
                }
                
                if dailyNotes.isEmpty {
                    Text("Tidak ada catatan pada hari ini")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    DailyNotesView(notes: dailyNotes)
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
    struct DailyNotesView: View {
        let notes: [Note]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(notes, id: \.id) { note in
                    Text(note.note)
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
