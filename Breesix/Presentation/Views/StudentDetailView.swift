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
    @State private var notes: [Note] = []
    @State private var selectedDate = Date()
    @State private var selectedNote: Note?
    @State private var isAddingNewNote = false
    @State private var isAddingNewActivity = false
    @State private var activity: Activity?
    @State private var activities: [Activity] = []
    @State private var isShowingCalendar: Bool = false
    @State private var showTabBar = false
    
    private let calendar = Calendar.current
    
    init(student: Student, viewModel: StudentListViewModel) {
        self.student = student
        self.viewModel = viewModel
        
        // Configure the navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.43, green: 0.64, blue: 0.32, alpha: 1.0)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Make the navigation bar buttons white
        UINavigationBar.appearance().tintColor = .white
    }
    
    private var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 8) {
                ProfileHeader(student: student)
                
                VStack(spacing: 8) {
                    
                    // Rest of your view...
                    HStack {
                        Text(formattedMonth)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 8) {
                            Button(action: { moveMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.green)
                            }
                            
                            Button(action: { moveMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.green)
                            }
                        }
                         
                        Spacer()
                        
                        CalendarButton(selectedDate: $selectedDate,
                                       isShowingCalendar: $isShowingCalendar)
                    }
                    .padding(.horizontal, 16)
                    
                    ScrollView {
                        ForEach(activitiesForSelectedMonth.keys.sorted(), id: \.self) { day in
                            VStack(alignment: .leading) {
                                Text("\(day, formatter: dateFormatter)") // Show the day
                                    .font(.headline)
                                    .padding(.top)
                                    .padding(.horizontal, 16)
                                    .foregroundStyle(Color.customGreen.g300)
                                
                                ActivityCardView(
                                    viewModel: viewModel,
                                    activities: activitiesForSelectedMonth[day] ?? [],
                                    notes: notesForSelectedMonth[day] ?? [],
                                    onAddNote: { isAddingNewNote = true },
                                    onAddActivity: { isAddingNewActivity = true },
                                    onEditActivity: { self.activity = $0 },
                                    onDeleteActivity: deleteActivity,
                                    onEditNote: { self.selectedNote = $0 },
                                    onDeleteNote: deleteNote
                                )
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .background(Color(red: 0.94, green: 0.95, blue: 0.93))
            }
        }
        .toolbar(showTabBar ? .visible : .hidden , for: .tabBar)
        .onDisappear {
                showTabBar = true
        }
        .navigationTitle("Profil Murid")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Edit") {
            isEditing = true
        }
            .foregroundColor(.white))
        // Rest of your modifiers...
        .sheet(isPresented: $isEditing) {
            StudentEditView(viewModel: viewModel, mode: .edit(student))
        }
        .sheet(item: $selectedNote) { note in
            NoteEditView(viewModel: viewModel, note: note, onDismiss: {
                selectedNote = nil
            })
        }
        .sheet(item: $activity) { currentActivity in
            ActivityEditView(viewModel: viewModel, activity: currentActivity, onDismiss: {
                activity = nil
            })
        }
        .sheet(isPresented: $isAddingNewNote) {
            NewNoteView(viewModel: viewModel,
                        student: student,
                        selectedDate: selectedDate,
                        onDismiss: {
                isAddingNewNote = false
                Task {
                    await fetchAllNotes()
                }
            })
        }
        .sheet(isPresented: $isAddingNewActivity) {
            NewActivityView(viewModel: viewModel,
                            student: student,
                            selectedDate: selectedDate,
                            onDismiss: {
                isAddingNewActivity = false
                Task {
                    await fetchActivities()
                }
            })
        }
        .task {
            await fetchAllNotes()
            await fetchActivities()
        }
    }
    
    // Rest of the code remains the same...
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
        }
    }
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private var activitiesForSelectedMonth: [Date: [Activity]] {
        Dictionary(grouping: activities) { activity in
            calendar.startOfDay(for: activity.createdAt)
        }.filter { date, _ in
            calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
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

struct CalendarButton: View {
    @Binding var selectedDate: Date
    @Binding var isShowingCalendar: Bool
    
    var body: some View {
        Button(action: { isShowingCalendar = true }) {
            HStack(spacing: 8) {
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
