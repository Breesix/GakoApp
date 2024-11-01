//
//  StudentDetailView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

struct StudentDetailView: View {
    let student: Student
    @ObservedObject var viewModel: StudentTabViewModel
    @State private var isEditing = false
    @State private var notes: [Note] = []
    @State private var selectedDate = Date()
    @State private var selectedNote: Note?
    @State private var isAddingNewNote = false
    @State private var isAddingNewActivity = false
    @State private var activity: Activity?
    @State private var activities: [Activity] = []
    @State private var isShowingCalendar: Bool = false
    @State private var showTabBar = false
    @State private var noActivityAlertPresented = false
    @State private var isTabBarHidden = true
    private let calendar = Calendar.current
    @Environment(\.presentationMode) var presentationMode
    
    init(student: Student, viewModel: StudentTabViewModel) {
        self.student = student
        self.viewModel = viewModel
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Color(.bgSecondary)
                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(edges: .top)
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            isTabBarHidden = false
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Text("Kembali")
                                    .foregroundStyle(.white)
                                    .fontWeight(.regular)
                            }
                            .font(.body)
                        }
                        Spacer()
                        
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Edit Profil")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .fontWeight(.regular)
                        }
                    }
                    .padding(14)
                }
                .frame(height: 58)
                
                ProfileHeader(student: student)
                    .padding(16)
                
                Divider()
                
                VStack(spacing: 0) {
                    HStack {
                        Text(formattedMonth)
                            .fontWeight(.semibold)
                            .foregroundColor(.labelPrimaryBlack)
                        
                        HStack(spacing: 8) {
                            Button(action: { moveMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.buttonLinkOnSheet)
                            }
                            
                            Button(action: { moveMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.buttonLinkOnSheet)
                            }
                        }
                        
                        Spacer()
                        CalendarButton(
                            selectedDate: $selectedDate,
                            isShowingCalendar: $isShowingCalendar,
                            onDateSelected: { newDate in
                                if activitiesForSelectedMonth[calendar.startOfDay(for: newDate)] != nil {
                                } else {
                                    if selectedDate > Date() {
                                        noActivityAlertPresented = true
                                    } else {
                                        noActivityAlertPresented = false
                                    }
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    if activitiesForSelectedMonth.isEmpty {
                        VStack {
                            Spacer()
                            EmptyState(message: "Belum ada aktivitas yang tercatat.")
                            Spacer()
                        }
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(activitiesForSelectedMonth.keys.sorted()), id: \.self) { day in
                                        if let dayItems = activitiesForSelectedMonth[day] {
                                            DailyReportCard(
                                                viewModel: viewModel,
                                                activities: dayItems.activities,
                                                notes: dayItems.notes,
                                                student: student,
                                                date: day,
                                                onAddNote: {
                                                    selectedDate = day
                                                    isAddingNewNote = true
                                                },
                                                onAddActivity: {
                                                    selectedDate = day
                                                    isAddingNewActivity = true
                                                },
                                                onDeleteActivity: deleteActivity,
                                                onEditNote: { self.selectedNote = $0 },
                                                onDeleteNote: deleteNote
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 12)
                                            .id(day)
                                        }
                                    }
                                }
                            }
                            .onChange(of: selectedDate) {
                                let startOfDay = calendar.startOfDay(for: selectedDate)
                                if let dayItems = activitiesForSelectedMonth[startOfDay] {
                                    if dayItems.activities.isEmpty && dayItems.notes.isEmpty && selectedDate > Date() {
                                        noActivityAlertPresented = true
                                    } else {
                                        withAnimation(.smooth) {
                                            scrollProxy.scrollTo(startOfDay, anchor: .top)
                                        }
                                        isShowingCalendar = false
                                    }
                                } else {
                                    noActivityAlertPresented = true
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .hideTabBar()
        }
        .toolbar(.hidden, for: .bottomBar , .tabBar )
        .sheet(isPresented: $isEditing) {
            EditStudent(viewModel: viewModel, mode: .edit(student))
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.white)
        }
        .sheet(item: $selectedNote) { note in
            EditNote(viewModel: viewModel, note: note, onDismiss: {
                selectedNote = nil
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .sheet(isPresented: $isAddingNewNote) {
            AddNote(viewModel: viewModel,
                        student: student,
                        selectedDate: selectedDate,
                        onDismiss: {
                isAddingNewNote = false
                Task {
                    await fetchAllNotes()
                }
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        
        .sheet(isPresented: $isAddingNewActivity) {
            AddActivity(viewModel: viewModel,
                            student: student,
                            selectedDate: selectedDate,
                            onDismiss: {
                isAddingNewActivity = false
                Task {
                    await fetchActivities()
                }
            })
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .alert("No Activity", isPresented: $noActivityAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("There are no activities recorded for the selected date.")
        }
        .task {
            await fetchAllNotes()
            await fetchActivities()
        }
    }
    
    private var activityThatDay: [Activity] {
        activities.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
    }
    
    private var filteredNotes: [Note] {
        notes.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
    }
    
    private func fetchAllNotes() async {
        notes = await viewModel.fetchAllNotes(student)
    }
    
    private func fetchActivities() async {
        activities = await viewModel.fetchActivities(student)
    }
    
    private func deleteNote(_ note: Note) {
        Task {
            await viewModel.deleteNote(note, from: student)
            notes.removeAll(where: { $0.id == note.id })
        }
    }
    
    private func deleteActivity(_ activity: Activity) {
        Task {
            await viewModel.deleteActivities(activity, from: student)
            activities.removeAll(where: { $0.id == activity.id })
            await fetchActivities()
        }
    }
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    
    private var activitiesForSelectedMonth: [Date: DayItems] {
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return [:]
        }
        
        let groupedActivities = Dictionary(grouping: activities) { activity in
            calendar.startOfDay(for: activity.createdAt)
        }
        
        let groupedNotes = Dictionary(grouping: notes) { note in
            calendar.startOfDay(for: note.createdAt)
        }
        
        var result: [Date: DayItems] = [:]
        
        var currentDate = startOfMonth
        while currentDate <= endOfMonth {
            if !(currentDate > Date()) {
                let startOfDay = calendar.startOfDay(for: currentDate)

                result[startOfDay] = DayItems(
                    activities: groupedActivities[startOfDay] ?? [],
                    notes: groupedNotes[startOfDay] ?? []
                )
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return result
    }
    
    func updateActivityStatus(_ activityId: UUID, isIndependent: Bool?) async {
        if let index = activities.firstIndex(where: { $0.id == activityId }) {
            
            activities[index].isIndependent = isIndependent
            
            await viewModel.updateActivityStatus(activities[index], isIndependent: isIndependent)
        }
    }

    
    private var notesForSelectedMonth: [Date: [Note]] {
        Dictionary(grouping: notes) { note in
            calendar.startOfDay(for: note.createdAt)
        }.filter { date, _ in
            calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
        }
    }
}

struct DayItems {
    var activities: [Activity]
    var notes: [Note]
}
