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
        HStack(alignment: .center, spacing: 16) {
            if let imageData = student.imageData {
                Image(uiImage: UIImage(data: imageData)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("\(student.nickname)")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("\(student.fullname)")
                    .font(.subheadline)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.leading, 16)
        .padding(.trailing, 32)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        
        WeeklyDatePickerView(selectedDate: $selectedDate)
        ScrollView {
            Button(action: {
                isShowingCalendar = true
            }) {
                HStack(spacing: 8) {
                    Text("\(formattedMonth)")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "calendar")
                }
                .padding(.all)
                .background(Color(red: 0.92, green: 0.96, blue: 0.96))
                .cornerRadius(10)
            }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker("Tanggal", selection: $selectedDate, displayedComponents: .date)
                .onChange(of: selectedDate) { oldValue, newValue in
                    Task {
                        await loadActivities()
                        await loadToiletTrainingStudents()
                    }
                }
                .datePickerStyle(.graphical)
                .presentationDetents([.fraction(0.5)])
        }
            
            if selectedDate > Date() {
                VStack {
                    Spacer()
                    Text("Sampai jumpa besok!")
                        .foregroundColor(.secondary)
                        .fontWeight(.semibold)
                }
            } else {
                VStack(alignment: .trailing, spacing: 4) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Footnote/Emphasized
                            Text("Toilet Training")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
                            
                            if toiletThatDay.isEmpty {
                                Text("Tidak ada toilet training untuk tanggal ini")
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(toiletTrainingStudent, id: \.id) { training in
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
                                    HStack(alignment: .center, spacing: 10) {
                                        Text(training.trainingDetail)
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                                        
                                            .frame(maxWidth: .infinity, alignment: .topLeading)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .frame(width: .infinity, alignment: .center)
                                    .background(.white)
                                    .cornerRadius(8)
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
                        .padding(0)
                        VStack(alignment: .leading, spacing: 8) {
                            // Footnote/Emphasized
                            Text("Aktivitas Umum")
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
                            if filteredActivities.isEmpty {
                                Text("Tidak ada catatan untuk tanggal ini")
                                    .foregroundColor(.secondary)
                            } else {
                                
                                ForEach(filteredActivities, id: \.id) { activity in
                                    HStack(alignment: .center, spacing: 10) {
                                        Text("\(activity.generalActivity)")
                                            .font(.caption)
                                            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                                            .frame(maxWidth: .infinity, alignment: .topLeading)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .frame(width: .infinity, alignment: .center)
                                    .background(.white)
                                    .cornerRadius(8)
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
                                Label("Tambah", systemImage: "plus.app.fill")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(0)
                        
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .background(Color(red: 0.92, green: 0.96, blue: 0.96))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.25)
                        .stroke(.green, lineWidth: 0.5)
                )
                .onChange(of: viewModel.students) { _, _ in
                    Task {
                        await loadActivities()
                    }
                }

            }
            
            //MARK: Card for Toilet Training and Aktivitas Umum
            
        }
        .padding(.horizontal, 16)
        
        .navigationTitle("Profil Murid")
        .navigationBarTitleDisplayMode(.inline)
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
        }
        
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "eeee, dd MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func loadActivities() async {
        activities = await viewModel.getActivitiesForStudent(student)
    }
    
    private var toiletThatDay: [ToiletTraining] {
        return toiletTrainings.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }    }
    
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
}





