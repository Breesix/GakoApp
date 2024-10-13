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
    @State private var activity: Activity?
    @State private var activities: [Activity] = []
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
                        activities: activityThatDay,
                        notes: filteredNotes,
                        onAddNote: { isAddingNewNote = true },
                        onEditActivity: { self.activity = $0 },
                        onDeleteActivity: deleteActivity,
                        onEditNote: { self.selectedNote = $0 },
                        onDeleteNote: deleteNote
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
            NewNoteView(viewModel: viewModel, student: student, selectedDate: selectedDate, onDismiss: {
                isAddingNewNote = false
                Task {
                    await fetchAllNotes()
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
}

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
