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
    @State private var isShowingMandatorySheet = false
    @State private var isShowingToiletTrainingSheet = false
    @State private var isAllStudentsFilled = true // Add this state to track student completion

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // ...
                    VStack(alignment: .leading, spacing: 16) {
                        DatePicker("Select Date", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                            .labelsHidden()
                        
                        Text(viewModel.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        isShowingMandatorySheet = true
                    }) {
                        Text("Mandatory Disokin")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        isShowingReflectionSheet = true
                    }) {
                        Text("CURHAT DONG MAH")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Curhat")
        }
        .sheet(isPresented: $isShowingReflectionSheet) {
            ReflectionInputView(
                viewModel: studentListViewModel,
                isShowingPreview: $isShowingPreview,
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
                isShowingPreview: $isShowingPreview
            )
        }
        
        .sheet(isPresented: $isShowingMandatorySheet) {
            MandatoryInputView(
                viewModel: studentListViewModel,
                isShowingTrainingPreview: $isShowingToiletTrainingSheet,
                isAllStudentsFilled: $isAllStudentsFilled,
                selectedDate: viewModel.selectedDate,
                onDismiss: {
                    isShowingMandatorySheet = false
                    isShowingToiletTrainingSheet = true
                }
            )
        }
        
        .sheet(isPresented: $isShowingToiletTrainingSheet) {
            TrainingPreviewView(viewModel: studentListViewModel, isShowingToiletTraining: $isShowingToiletTrainingSheet)
        }
    }
}

enum ActiveSheet: Identifiable {
    case reflection
    case preview
    case mandatory
    case toiletTraining

    var id: Int {
        hashValue
    }
}
