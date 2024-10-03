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
            }
            .onChange(of: viewModel.students) { _, _ in
                Task {
                    await loadActivities()
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
        .task {
            await loadActivities()
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
}
