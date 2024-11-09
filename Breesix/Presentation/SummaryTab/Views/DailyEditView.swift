//
//  DailyEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 09/11/24.
//

import SwiftUI

struct DailyEditView: View {
    let student: Student
    let selectedDate: Date
    let onUpdateActivity: (Activity, Status) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    
    @Environment(\.dismiss) var dismiss
    @State private var activities: [Activity] = []
    @State private var notes: [Note] = []
    @State private var editedActivities: [UUID: (String, Status, Date)] = [:]
    @State private var editedNotes: [UUID: (String, Date)] = [:]
    @State private var showingDeleteAlert = false
    @State private var itemToDelete: Any?
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showingCancelAlert = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(formattedDate)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    if let items = activitiesForSelectedDay {
                        DayEditCard(
                            date: selectedDate,
                            activities: items.activities,
                            notes: items.notes,
                            editedActivities: $editedActivities,
                            editedNotes: $editedNotes,
                            onDeleteActivity: { activity in
                                itemToDelete = activity
                                showingDeleteAlert = true
                            },
                            onDeleteNote: { note in
                                itemToDelete = note
                                showingDeleteAlert = true
                            }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .padding(.bottom, 80)
            }
            .background(.bgMain)
            
            // Sticky Save Button
            VStack {
                HStack(spacing: 16) {
                    Button {
                        showingCancelAlert = true
                    } label: {
                        Text("Batal")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.destructiveOnCardLabel)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.buttonDestructiveOnCard))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        Task {
                            await saveChanges()
                        }
                    } label: {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.labelPrimaryBlack)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.orangeClickAble))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color.white)
        }
        .toolbar(.hidden, for: .bottomBar, .tabBar)
        .hideTabBar()
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Edit Dokumentasi")
        .alert("Peringatan", isPresented: $showingDeleteAlert) {
            Button("Hapus", role: .destructive) {
                Task {
                    if let activity = itemToDelete as? Activity {
                        await onDeleteActivity(activity, student)
                        activities.removeAll(where: { $0.id == activity.id })
                    } else if let note = itemToDelete as? Note {
                        await onDeleteNote(note, student)
                        notes.removeAll(where: { $0.id == note.id })
                    }
                }
            }
            Button("Batal", role: .cancel) {}
        } message: {
            Text("Apakah Anda yakin ingin menghapus item ini?")
        }
        .alert("Peringatan", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await fetchData()
        }
        .alert("Peringatan", isPresented: $showingCancelAlert) {
            Button("Ya", role: .destructive) {
                dismiss()
            }
            Button("Tidak", role: .cancel) { }
        } message: {
            Text("Apakah Anda yakin ingin membatalkan perubahan?")
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var activitiesForSelectedDay: DayItems? {
        let dayActivities = activities.filter { calendar.isDate($0.createdAt, equalTo: selectedDate, toGranularity: .day) }
        let dayNotes = notes.filter { calendar.isDate($0.createdAt, equalTo: selectedDate, toGranularity: .day) }
        return DayItems(activities: dayActivities, notes: dayNotes)
    }
    
    private func fetchData() async {
        activities = await onFetchActivities(student)
        notes = await onFetchNotes(student)
    }
    
    private func saveChanges() async {
        // Handle edited and new activities
        for (id, (text, status, date)) in editedActivities {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                alertMessage = "Aktivitas tidak boleh kosong"
                showAlert = true
                return
            }
            
            let activity = activities.first(where: { $0.id == id })
            let updatedActivity = activity.map { act -> Activity in
                var updated = act
                updated.activity = trimmedText
                updated.status = status
                return updated
            } ?? Activity(
                activity: trimmedText,
                createdAt: date,
                status: status,
                student: student
            )
            
            await onUpdateActivity(updatedActivity, status)
            if activity == nil {
                activities.append(updatedActivity)
            }
        }
        
        // Handle edited and new notes
        for (id, (text, date)) in editedNotes {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                alertMessage = "Catatan tidak boleh kosong"
                showAlert = true
                return
            }
            
            let note = notes.first(where: { $0.id == id })
            let updatedNote = note.map { n -> Note in
                var updated = n
                updated.note = trimmedText
                return updated
            } ?? Note(
                note: trimmedText,
                createdAt: date,
                student: student
            )
            
            await onUpdateNote(updatedNote)
            if note == nil {
                notes.append(updatedNote)
            }
        }
        
        activities = await onFetchActivities(student)
        notes = await onFetchNotes(student)
        dismiss()
    }
}

#Preview {
    DailyEditView(
        student: Student(fullname: "John Doe", nickname: "John"),
        selectedDate: Date(),
        onUpdateActivity: { _, _ in },
        onUpdateNote: { _ in },
        onDeleteActivity: { _, _ in },
        onDeleteNote: { _, _ in },
        onFetchNotes: { _ in return [] },
        onFetchActivities: { _ in return [] }
    )
}
