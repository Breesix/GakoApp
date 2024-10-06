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
    @State private var selectedInputType: InputType = .manual
    @State private var isShowingReflectionSheet = false
    @State private var isShowingPreview = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // DatePicker to select the date
                    DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    
                    Text(viewModel.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Suara and Teks buttons
                    HStack(alignment: .center) {
                        
                        VStack(alignment: .leading) {
                            Text("Suara")
                                .font(.headline)
                                .padding()
                            Button(action: {
                                isShowingReflectionSheet = true
                                selectedInputType = .speech
                            }) {
                                Text("CURHAT DONG MAH")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        .background(Color.gray)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading) {
                            Text("Teks")
                                .font(.headline)
                                .padding()
                            Button(action: {
                                isShowingReflectionSheet = true
                                selectedInputType = .manual
                            }) {
                                Text("CURHAT DONG MAH")
                                
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        .background(Color.gray)
                        .cornerRadius(8)
                    }
                    
                    // Insight section
                    VStack(alignment: .leading) {
                        Text("Insight Hari ini")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .padding(.vertical)
                        
                        Text("Tulis insight atau catatan penting di sini...")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, minHeight: 100)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity, minHeight: 100)
                    )
                    
                    ForEach(studentListViewModel.students, id: \.id) { student in
                        studentDetail(for: student)
                            .onAppear {
                                Task {
                                    await studentListViewModel.loadStudents()
                                    
                                }
                            }
                    }
                }
                .padding()
                .navigationTitle("Curhat")
            }
            .sheet(isPresented: $isShowingReflectionSheet) {
                ReflectionInputView(
                    viewModel: studentListViewModel,
                    isShowingPreview: $isShowingPreview,
                    inputType: selectedInputType,
                    selectedDate: viewModel.selectedDate,
                    onDismiss: {
                        isShowingReflectionSheet = false
                        isShowingPreview = true
                    }
                )
            }
            .sheet(isPresented: $isShowingPreview, onDismiss: {
                studentListViewModel.clearUnsavedActivities()
            }) {
                ReflectionPreviewView(
                    viewModel: studentListViewModel,
                    isShowingPreview: $isShowingPreview,
                    selectedDate: viewModel.selectedDate
                )
            }
        }
        
        
    }
    private func studentDetail(for student: Student) -> some View {
        NavigationLink(destination: StudentDetailView(student: student, viewModel: studentListViewModel)) {
            VStack(alignment: .leading, spacing: 10) {
                Text(student.nickname)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Filter today's activities
                let todayActivities: [Activity] = student.activities.filter {
                    Calendar.current.isDate($0.createdAt, inSameDayAs: viewModel.selectedDate)
                }
                
                if todayActivities.isEmpty {
                    Text("No activities for selected date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ForEach(todayActivities, id: \.id) { a  ctivity in
                        Text(activity.generalActivity)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.gray)
            .cornerRadius(8)
        }
    }
}

