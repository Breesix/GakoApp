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
    
    // Add this to handle tab bar visibility
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
            
            VStack(spacing: 8) {
                
                ZStack {
                    Color(.bgSecondary)
                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(edges: .top)
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 16) {
                            Button(action: {
                                // Show tab bar before dismissing
                                isTabBarHidden = false
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                    Text("Murid")
                                        .foregroundStyle(.white)
                                }
                            }
                            Spacer()
                            
                            Button(action: {
                                isEditing = true
                            }) {
                                HStack(spacing: 4) {
                                    Text("Edit Profil")
                                        .foregroundStyle(.white)
                                }
                                // Reduce left padding to move closer to edge
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                }
                .frame(height: 58)
                
                ProfileHeader(student: student)
                
                VStack(spacing: 8) {
                    HStack {
                        Text(formattedMonth)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 8) {
                            Button(action: { moveMonth(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(Color(red: 1, green: 0.68, blue: 0.12))
                            }
                            
                            Button(action: { moveMonth(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(Color(red: 1, green: 0.68, blue: 0.12))
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
                    .padding(.vertical, 12)
                    
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            ForEach(activitiesForSelectedMonth.keys.sorted(), id: \.self) { day in
                                ActivityCard(
                                    activities: activitiesForSelectedMonth[day] ?? [],
                                    notes: notesForSelectedMonth[day] ?? [],
                                    date: day,
                                    onAddNote: { isAddingNewNote = true },
                                    onAddActivity: { isAddingNewActivity = true },
                                    onEditActivity: { self.activity = $0 },
                                    onDeleteActivity: deleteActivity,
                                    onEditNote: { self.selectedNote = $0 },
                                    onDeleteNote: deleteNote
                                )
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .id(day)
                            }
                        }
                        .onChange(of: selectedDate) { newDate in
                            if let activitiesOnSelectedDate = activitiesForSelectedMonth[calendar.startOfDay(for: newDate)] {
                                if activitiesOnSelectedDate.isEmpty {
                                    noActivityAlertPresented = true
                                } else {
                                    withAnimation(.smooth) {
                                        scrollProxy.scrollTo(calendar.startOfDay(for: newDate), anchor: .top)
                                    }
                                    isShowingCalendar = false
                                }
                            } else {
                                noActivityAlertPresented = true
                            }
                        }
                        //                        .onChange(of: selectedDate) { newDate in
                        //                            if let activitiesOnSelectedDate = activitiesForSelectedMonth[calendar.startOfDay(for: newDate)] {
                        //                                if activitiesOnSelectedDate.isEmpty {
                        //                                    noActivityAlertPresented = true
                        //                                } else {
                        //                                    // Close the calendar and scroll to the activity card
                        //                                    scrollProxy.scrollTo(calendar.startOfDay(for: newDate), anchor: .top)
                        //                                    isShowingCalendar = false
                        //                                }
                        //                            }
                        //                        }
                    }
                }
                .background(Color(red: 0.94, green: 0.95, blue: 0.93))
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onDisappear {
            // Ensure tab bar is shown when view disappears
            isTabBarHidden = false
        }
        .navigationBarHidden(true) // Add this line
        //        .toolbarBackground(Color(red: 0.43, green: 0.64, blue: 0.32), for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        //
        //        .navigationBarTitleDisplayMode(.inline)
        //        .navigationBarItems(
        //            leading: BackButton(),
        //            trailing: Button("Edit Profil") {
        //                isEditing = true
        //            }
        //                .foregroundColor(.white)
        //        )
        
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
            Label("Kalender", systemImage: "calendar")
        }
        .frame(width: 34, height: 34)
        .labelStyle(.iconOnly)
        .buttonStyle(.bordered)
        .foregroundStyle(.white)
        .background(Color(red: 1, green: 0.68, blue: 0.12))
        .cornerRadius(999)
        
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker("Tanggal", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "id_ID")) // Set locale to Indonesian
                .presentationDetents([.fraction(0.55)])
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

struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                Text("Murid")
                    .foregroundStyle(.white)
            }
            // Reduce left padding to move closer to edge
        }
    }
}

//struct EditProfilButton: View {
//    @Environment(\.presentationMode) var presentationMode
//
//    var body: some View {
//        Button(action: {
//            isEditing = true
//        }) {
//            HStack(spacing: 4) {
//                Text("Edit Profil")
//                    .foregroundStyle(.white)
//            }
//             // Reduce left padding to move closer to edge
//        }
//    }
//}
