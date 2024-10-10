//
//  StudentDetailView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

struct StudentDetailView: View {
    let student: Student
    @ObservedObject var viewModel: StudentListViewModel
    @State private var isEditing = false
    @State private var activities: [Activity] = []
    @State private var selectedDate = Date()
    @State private var selectedActivity: Activity?
    @State private var isAddingNewActivity = false
    @State private var selectedTraining: ToiletTraining?
    @State private var toiletTrainings: [ToiletTraining] = []
    @State private var isShowingCalendar: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                StudentHeaderView(student: student)
                WeeklyDatePickerView(selectedDate: $selectedDate)
                CalendarButton(selectedDate: $selectedDate, isShowingCalendar: $isShowingCalendar)
                
                if selectedDate > Date() {
                    FutureMessageView()
                } else {
                    ActivityCardView(
                        toiletTrainings: toiletThatDay,
                        activities: filteredActivities,
                        onAddActivity: { isAddingNewActivity = true },
                        onEditTraining: { self.selectedTraining = $0 },
                        onDeleteTraining: deleteTraining,
                        onEditActivity: { self.selectedActivity = $0 },
                        onDeleteActivity: deleteActivity
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle("Profil Murid")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: EditButton(isEditing: $isEditing))
        .sheet(isPresented: $isEditing) {
            StudentEditView(viewModel: viewModel, mode: .edit(student))
        }
        .sheet(item: $selectedActivity) { activity in
            ActivityEditView(viewModel: viewModel, activity: activity, onDismiss: {
                selectedActivity = nil
            })
        }
        .sheet(item: $selectedTraining) { training in
            TrainingEditView(viewModel: viewModel, training: training, onDismiss: {
                selectedTraining = nil
            })
        }
        .sheet(isPresented: $isAddingNewActivity) {
            NewActivityView(viewModel: viewModel, student: student, selectedDate: selectedDate, onDismiss: {
                isAddingNewActivity = false
                Task {
                    await loadActivities()
                }
            })
        }
        .task {
            await loadActivities()
            await loadToiletTrainingStudents()
        }
    }
    
    // MARK: - Helper Methods
    private var toiletThatDay: [ToiletTraining] {
        toiletTrainings.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
    }
    
    private var filteredActivities: [Activity] {
        activities.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
    }
    
    private func loadActivities() async {
        activities = await viewModel.getActivitiesForStudent(student)
    }
    
    private func loadToiletTrainingStudents() async {
        toiletTrainings = await viewModel.getToiletTrainingForStudent(student)
    }
    
    private func deleteActivity(_ activity: Activity) {
        Task {
            await viewModel.deleteActivity(activity, from: student)
            activities.removeAll(where: { $0.id == activity.id })
        }
    }
    
    private func deleteTraining(_ training: ToiletTraining) {
        Task {
            await viewModel.deleteToiletTraining(training, from: student)
            toiletTrainings.removeAll(where: { $0.id == training.id })
        }
    }
}

// MARK: - Subcomponents

struct CalendarButton: View {
    @Binding var selectedDate: Date
    @Binding var isShowingCalendar: Bool
    
    var body: some View {
        Button(action: { isShowingCalendar = true }) {
            HStack(spacing: 8) {
                Text(formattedMonth)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "calendar")
            }
            .padding()
            .background(Color(red: 0.92, green: 0.96, blue: 0.96))
            .cornerRadius(10)
        }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker("Tanggal", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .presentationDetents([.fraction(0.5)])
        }
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "eeee, dd MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
}

struct FutureMessageView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Sampai jumpa besok!")
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
        }
    }
}


struct EditButton: View {
    @Binding var isEditing: Bool
    
    var body: some View {
        Button("Edit") {
            isEditing = true
        }
    }
}
