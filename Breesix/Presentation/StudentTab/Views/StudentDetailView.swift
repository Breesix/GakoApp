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
    @State private var noActivityAlertPresented = false
    
    private let calendar = Calendar.current
    
    init(student: Student, viewModel: StudentTabViewModel) {
        self.student = student
        self.viewModel = viewModel
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
                        CalendarButton(
                            selectedDate: $selectedDate,
                            isShowingCalendar: $isShowingCalendar,
                            onDateSelected: { newDate in
                                if let activitiesOnSelectedDate = activitiesForSelectedMonth[calendar.startOfDay(for: newDate)] {
                                    if activitiesOnSelectedDate.isEmpty {
                                        noActivityAlertPresented = true
                                    } else {
                                        isShowingCalendar = false
                                    }
                                } else {
                                    noActivityAlertPresented = true
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 16)
                    
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            ForEach(activitiesForSelectedMonth.keys.sorted(), id: \.self) { day in
                                VStack(alignment: .leading) {
                                    Text("\(day, formatter: dateFormatter)") // Show the day
                                        .font(.headline)
                                        .padding(.top)
                                        .padding(.horizontal, 16)
                                        .foregroundStyle(Color.customGreen.g300)
                                    
                                    ActivityCard(
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
                                    .id(day) // Assign an ID for scrolling
                                }
                            }
                        }
                        .onChange(of: selectedDate) { newDate in
                            if let activitiesOnSelectedDate = activitiesForSelectedMonth[calendar.startOfDay(for: newDate)] {
                                if activitiesOnSelectedDate.isEmpty {
                                    noActivityAlertPresented = true
                                } else {
                                    // Close the calendar and scroll to the activity card
                                    scrollProxy.scrollTo(calendar.startOfDay(for: newDate), anchor: .top)
                                    isShowingCalendar = false
                                }
                            }
                        }
                    }
                }
                .background(Color(red: 0.94, green: 0.95, blue: 0.93))
            }
        }
        .alert(isPresented: $noActivityAlertPresented) {
            Alert(title: Text("No Activities"), message: Text("No activities found for the selected date."), dismissButton: .default(Text("OK")))
        }
        .toolbarBackground(Color(red: 0.43, green: 0.64, blue: 0.32), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle("Profil Murid")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button("Edit") {
            isEditing = true
        }
            .foregroundColor(.white))
        
        .sheet(isPresented: $isEditing) {
            StudentEditView(viewModel: viewModel, mode: .edit(student))
        }
        .sheet(item: $selectedNote) { note in
            NoteEditView(viewModel: viewModel, note: note, onDismiss: {
                selectedNote = nil
            })
        }
        .sheet(item: $activity) { currentActivity in
            ActivityEdit(viewModel: viewModel, activity: currentActivity, onDismiss: {
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
    var onDateSelected: (Date) -> Void // Closure for date selection
    
    var body: some View {
        Button(action: { isShowingCalendar = true }) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
            }
            .padding()
            .background(Color(red: 0.43, green: 0.64, blue: 0.32))
            .cornerRadius(999)
        }
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker("Tanggal", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .presentationDetents([.fraction(0.55)])
                .tint(.green)
                .onChange(of: selectedDate) { newDate in
                    onDateSelected(newDate) // Call the closure when date changes
                }
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
