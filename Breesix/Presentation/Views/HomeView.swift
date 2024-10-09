//
//  HomeView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @ObservedObject var studentListViewModel: StudentListViewModel
    @State private var isShowingReflectionSheet = false
    @State private var isShowingPreview = false
    @State private var isShowingToiletTraining = false
    @State private var isShowingMandatorySheet = false
    @State private var selectedInputType: InputType = .manual
    @State private var isAllStudentsFilled = true
    @State private var activeSheet: ActiveSheet? = nil  // Manage sheets with enum
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    datePickerView()
                    
                    // Suara and Teks buttons
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text("Suara")
                                .font(.headline)
                                .padding()
                            Button(action: {
                                isShowingMandatorySheet = true
                                selectedInputType = .speech
                            }) {
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
                        
                        VStack(alignment: .leading) {
                            Text("Teks")
                                .font(.headline)
                                .padding()
                            Button(action: {
                                isShowingMandatorySheet = true 
                                selectedInputType = .manual
                            }) {
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

                    // List of Students
                    studentsListView()
                }
                .padding()
                // Load students when the view appears
                .task {
                    await studentListViewModel.loadStudents()
                }
            }
            .navigationTitle("Curhat")
            
            .sheet(isPresented: $isShowingMandatorySheet) {
                MandatoryInputView(
                    viewModel: studentListViewModel,
                    inputType: selectedInputType,
                    isAllStudentsFilled: $isAllStudentsFilled,
                    selectedDate: viewModel.selectedDate,
                    
                    onDismiss: {
                        isShowingMandatorySheet = false
                        isShowingReflectionSheet = true
                    }
                )
            }
            
            // Handle sheet presentation based on activeSheet
            .sheet(isPresented: $isShowingReflectionSheet) {
                ReflectionInputView(
                    viewModel: studentListViewModel,
                    speechRecognizer: SpeechRecognizer(),
                    isAllStudentsFilled: $isAllStudentsFilled,
                    inputType: selectedInputType,
                    selectedDate: viewModel.selectedDate,
                    onDismiss: {
                        isShowingReflectionSheet = false
                        isShowingPreview = true
                    }
                )
            }
            .sheet(isPresented: $isShowingPreview) {
                ReflectionPreviewView(
                    viewModel: studentListViewModel,
                    isShowingPreview: $isShowingPreview,
                    isShowingToiletTraining: $isShowingToiletTraining,
                    selectedDate: viewModel.selectedDate
                    
                )
            }
            
        }
    }
    
    
    @ViewBuilder
    private func datePickerView() -> some View {
        DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }
    @ViewBuilder
    private func inputButtonsView() -> some View {
        HStack(alignment: .center) {
            InputTypeButton(title: "Suara", action: {
                activeSheet = .mandatory
                selectedInputType = .speech
            })
            
            InputTypeButton(title: "Teks", action: {
                activeSheet = .mandatory
                selectedInputType = .manual
            })
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
        ForEach(studentListViewModel.students) { student in
            NavigationLink(destination: StudentDetailView(student: student, viewModel: studentListViewModel)) {
                StudentRowView(student: student, selectedDate: viewModel.selectedDate)
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(8)
        }
    }
    //  @ViewBuilder
    //    private func sheetContent(sheet: ActiveSheet) -> some View {
    //        switch sheet {
    //        case .mandatory:
    //            MandatoryInputView(
    //                viewModel: studentListViewModel,
    //                inputType: selectedInputType,
    //                isShowingTrainingPreview: .constant(false),
    //                isAllStudentsFilled: $isAllStudentsFilled,
    //                selectedDate: viewModel.selectedDate,
    //                onDismiss: {
    //                    activeSheet = .toiletTraining
    //                }
    //            )
    //        case .reflection:
    //            ReflectionInputView(
    //                viewModel: studentListViewModel, speechRecognizer: SpeechRecognizer(),
    //                isShowingPreview: .constant(false),
    //                inputType: selectedInputType,
    //                selectedDate: viewModel.selectedDate,
    //                onDismiss: {
    //                    activeSheet = .preview
    //                }
    //            )
    //        case .preview:
    //            ReflectionPreviewView(
    //                viewModel: studentListViewModel,
    //                isShowingPreview: .constant(true),
    //                selectedDate: viewModel.selectedDate
    //            )
    //        case .toiletTraining:
    //            TrainingPreviewView(
    //                viewModel: studentListViewModel,
    //                isShowingToiletTraining: .constant(true),
    //                onDismiss: {
    //                    activeSheet = .reflection
    //                }
    //            )
    //        }
    //    }
    //}
    
    struct StudentRowView: View {
        let student: Student
        let selectedDate: Date
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(student.fullname)
                    .font(.title)
                
                if let latestTraining = student.toiletTrainings.sorted(by: { $0.createdAt > $1.createdAt }).first {
                    ToiletTrainingView(training: latestTraining)
                }
                
                let dailyActivities = student.activities.filter {
                    Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
                }
                
                if dailyActivities.isEmpty {
                    Text("Tidak ada aktivitas umum pada hari ini")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    DailyActivitiesView(activities: dailyActivities)
                }
            }
        }
    }
    struct ToiletTrainingView: View {
        let training: ToiletTraining
        
        var body: some View {
            VStack(alignment: .leading) {
                
                if let status = training.status {
                    HStack {
                        Image(systemName: "toilet.fill")
                            .scaledToFit()
                            .foregroundColor(.white)
                        Text(status ? "Independent" : "Needs Guidance")
                            .font(.footnote)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    
                    
                } else {
                    Text("Tidak ada toilet training terbaru")
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
    struct DailyActivitiesView: View {
        let activities: [Activity]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                    ForEach(activities, id: \.id) { activity in
                        Text(activity.generalActivity)
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
    
    // ActiveSheet Enum to manage sheet presentations
    enum ActiveSheet: Identifiable {
        case reflection
        case preview
        case mandatory
        case toiletTraining
        
        var id: Int {
            hashValue
        }
    }
    
}
