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
    @State private var weeklySummary: WeeklySummary?
    @State private var isLoadingSummary = false
    @State private var summaryError: Error?
    @State private var weeklySummaries: [WeeklySummary] = []

    var body: some View {
        List {
            Section(header: Text("Informasi Murid")) {
                Text("Nama Lengkap: \(student.fullname)")
                Text("Nama Panggilan: \(student.nickname)")
            }

            Section(header: Text("Pilih Tanggal")) {
                DatePicker("Tanggal", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) { oldValue, newValue in
                        Task {
                            await loadActivities()
                        }
                    }
            }

            Section(header: Text("Aktivitas Umum")) {
                if filteredActivities.isEmpty {
                    Text("Tidak ada catatan untuk tanggal ini")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filteredActivities, id: \.id) { activity in
                        VStack(alignment: .leading) {
                            Text("\(activity.generalActivity)")
                        }
                        .contextMenu {
                            Button("Edit") {
                                self.selectedActivity = activity
                            }
                            Button("Hapus", role: .destructive) {
                                deleteActivity(activity)
                            }
                        }
                    }
                }
                
                Button(action: {
                    isAddingNewActivity = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Tambah Aktivitas Baru")
                    }
                }
            }
            .onChange(of: viewModel.students) { _, _ in
                Task {
                    await loadActivities()
                }
            }
            
            Section(header: Text("Toilet Training")) {
                if toiletTrainings.isEmpty {
                    Text("Tidak ada catatan untuk tanggal ini")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(toiletTrainingStudent, id: \.id) { training in
                        VStack(alignment: .leading) {
                            Text(training.trainingDetail)
                            
                            if let status = training.status {
                                if status {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Independent")
                                    }
                                    .foregroundColor(.green)
                                } else {
                                    HStack {
                                        Image(systemName: "xmark.circle.fill")
                                        Text("Needs Guidance")
                                    }
                                    .foregroundColor(.red)
                                }
                            }
                        }
                        .contextMenu {
                            Button("Edit") {
                                self.selectedTraining = training
                            }
                            Button("Hapus", role: .destructive) {
                                deleteTraining(training)
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.students) { _, _ in
                Task {
                    await loadToiletTrainingStudents()
                }
            }
            
            Section(header: Text("Weekly Summaries")) {
                     if weeklySummaries.isEmpty {
                         Text("No weekly summaries available")
                             .foregroundColor(.secondary)
                     } else {
                         ForEach(weeklySummaries) { summary in
                             NavigationLink(destination: WeeklySummaryDetailView(summary: summary)) {
                                 VStack(alignment: .leading) {
                                     Text("\(formatDate(summary.startDate)) - \(formatDate(summary.endDate))")
                                         .font(.headline)
                                     Text(summary.summary.prefix(50) + "...")
                                         .font(.subheadline)
                                         .foregroundColor(.secondary)
                                 }
                             }
                         }
                     }

                     Button("Generate New Summary") {
                         generateNewSummary()
                     }
                 }

        }
        .navigationTitle(student.nickname)
        .navigationBarItems(trailing: Button("Edit") {
            isEditing = true
        })
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
            loadWeeklySummaries()
        }

    }

    private func loadActivities() async {
        activities = await viewModel.getActivitiesForStudent(student)
    }

    private var filteredActivities: [Activity] {
        let filtered = activities.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
        return filtered
    }
    
    private func deleteActivity(_ activity: Activity) {
        Task {
            await viewModel.deleteActivity(activity, from: student)
            activities.removeAll(where: { $0.id == activity.id })
        }
    }
    
    private func loadToiletTrainingStudents() async {
        toiletTrainings = await viewModel.getToiletTrainingForStudent(student)
    }

    private var toiletTrainingStudent: [ToiletTraining] {
        let filtered = toiletTrainings.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
        return filtered
    }

    private func deleteTraining(_ training: ToiletTraining) {
        Task {
            await viewModel.deleteToiletTraining(training, from: student)
            toiletTrainings.removeAll(where: { $0.id == training.id })
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func loadWeeklySummaries() {
        weeklySummaries = viewModel.getWeeklySummariesForStudent(student)
    }

    private func generateNewSummary() {
        Task {
            do {
                try await viewModel.generateAndSaveWeeklySummary(for: student)
                loadWeeklySummaries()
            } catch {
                print("Error generating new summary: \(error)")
            }
        }
    }

}

struct WeeklySummaryDetailView: View {
    let summary: WeeklySummary

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(formatDate(summary.startDate)) - \(formatDate(summary.endDate))")
                    .font(.headline)
                
                Text(summary.summary)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Weekly Summary")
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
