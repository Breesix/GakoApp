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
    @State private var originalActivities: [Activity] = []
    @State private var originalNotes: [Note] = []
    @State private var tempEditedActivities: [UUID: (String, Status, Date)] = [:]
    @State private var tempEditedNotes: [UUID: (String, Date)] = [:]
    @State private var tempDeletedActivities: [Activity] = []
    @State private var tempDeletedNotes: [Note] = []

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
                if let activity = itemToDelete as? Activity {
                    // Simpan ke temporary deletion
                    tempDeletedActivities.append(activity)
                    activities.removeAll(where: { $0.id == activity.id })
                } else if let note = itemToDelete as? Note {
                    // Simpan ke temporary deletion
                    tempDeletedNotes.append(note)
                    notes.removeAll(where: { $0.id == note.id })
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
            // Simpan data original
            originalActivities = activities
            originalNotes = notes
        }

        .alert("Peringatan", isPresented: $showingCancelAlert) {
            Button("Ya", role: .destructive) {
                // Kembalikan ke state awal
                activities = originalActivities
                notes = originalNotes
                
                // Bersihkan semua perubahan temporary
                tempEditedActivities.removeAll()
                tempEditedNotes.removeAll()
                tempDeletedActivities.removeAll()
                tempDeletedNotes.removeAll()
                dismiss()
            }
            Button("Tidak", role: .cancel) {}
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
        // Validasi sebelum menyimpan
        for (id, (text, status, date)) in tempEditedActivities {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                alertMessage = "Aktivitas tidak boleh kosong"
                showAlert = true
                return
            }
            
            if let activity = activities.first(where: { $0.id == id }) {
                var updatedActivity = activity
                updatedActivity.activity = trimmedText
                updatedActivity.status = status
                await onUpdateActivity(updatedActivity, status)
            } else {
                // Handle new activity
                let newActivity = Activity(
                    activity: trimmedText,
                    createdAt: date,
                    status: status,
                    student: student
                )
                await onUpdateActivity(newActivity, status)
            }
        }

        // Proses edited notes
        for (id, (text, date)) in tempEditedNotes {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                alertMessage = "Catatan tidak boleh kosong"
                showAlert = true
                return
            }
            
            if let note = notes.first(where: { $0.id == id }) {
                var updatedNote = note
                updatedNote.note = trimmedText
                await onUpdateNote(updatedNote)
            } else {
                // Handle new note
                let newNote = Note(
                    note: trimmedText,
                    createdAt: date,
                    student: student
                )
                await onUpdateNote(newNote)
            }
        }

        // Proses penghapusan yang sudah dikonfirmasi
        for activity in tempDeletedActivities {
            await onDeleteActivity(activity, student)
        }
        
        for note in tempDeletedNotes {
            await onDeleteNote(note, student)
        }

        // Refresh data
        activities = await onFetchActivities(student)
        notes = await onFetchNotes(student)

        // Clear temporary changes
        tempEditedActivities.removeAll()
        tempEditedNotes.removeAll()
        tempDeletedActivities.removeAll()
        tempDeletedNotes.removeAll()
        
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
