import SwiftUI

struct MonthlyEditView: View {
    let student: Student
    let selectedMonth: Date
    @State private var currentSelectedDate: Date = Date()
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
    @State private var originalActivities: [Activity] = []
    @State private var originalNotes: [Note] = []
    @State private var showingCancelAlert = false
    @State private var tempDeletedActivities: [Activity] = []
    @State private var tempDeletedNotes: [Note] = []
    @State private var selectedStudent: Student?
    @State private var isAddingNewActivity: Bool = false
    @State private var showingAddActivity = false
    @State private var activityToEdit: Activity?
    @State private var selectedDate = Date()
    @State private var isShowingCalendar: Bool = false
    @State private var noActivityAlertPresented = false

    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Navbar
                ZStack {
                    Color(.bgSecondary)
                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(edges: .top)
                    
                    ZStack {
                        HStack(spacing: 0) {
                            Button(action: {
                                showingCancelAlert = true
                            }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Text("Batal")
                                        .foregroundStyle(.white)
                                        .fontWeight(.regular)
                                }
                                .font(.body)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 14)
                    }
                }
                .frame(height: 58)                
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(activitiesForSelectedMonth.keys.sorted()), id: \.self) { date in
                                if let items = activitiesForSelectedMonth[date] {
                                    MonthlyEditCard(
                                        date: date,
                                        activities: items.activities,
                                        notes: items.notes,
                                        student: student,
                                        selectedStudent: $selectedStudent,
                                        isAddingNewActivity: $showingAddActivity,
                                        editedActivities: $editedActivities,
                                        editedNotes: $editedNotes,
                                        onDeleteActivity: { activity in
                                            currentSelectedDate = date
                                            itemToDelete = activity
                                            showingDeleteAlert = true
                                        },
                                        onDeleteNote: { note in
                                            currentSelectedDate = date
                                            itemToDelete = note
                                            showingDeleteAlert = true
                                        },
                                        onActivityUpdate: { activity in
                                            currentSelectedDate = date
                                            activityToEdit = activity
                                        },
                                        onAddActivity: {
                                            currentSelectedDate = date
                                            showingAddActivity = true
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }   
                        .padding(.bottom, 80)
                    }
                    .background(.bgMain)
                    
                    VStack {
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
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .background(Color.bgMain)
                }
            }
        }
        .sheet(isPresented: $showingAddActivity) {
            ManageActivityView(
                mode: .add(student, currentSelectedDate),
                onSave: { newActivity in
                    Task {
                        activities.append(newActivity)
                        await onUpdateActivity(newActivity, newActivity.status)
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $activityToEdit) { activity in
            ManageActivityView(
                mode: .edit(activity),
                onSave: { updatedActivity in
                    Task {
                        if let index = activities.firstIndex(where: { $0.id == updatedActivity.id }) {
                            activities[index] = updatedActivity
                            await onUpdateActivity(updatedActivity, updatedActivity.status)
                        }
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .toolbar(.hidden, for: .bottomBar, .tabBar)
        .hideTabBar()
        .navigationBarBackButtonHidden(true)
        .alert("Peringatan", isPresented: $showingDeleteAlert) {
            Button("Hapus", role: .destructive) {
                if let activity = itemToDelete as? Activity {
                    tempDeletedActivities.append(activity)
                    activities.removeAll(where: { $0.id == activity.id })
                } else if let note = itemToDelete as? Note {
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
            originalActivities = activities
            originalNotes = notes
        }
        .alert("Peringatan", isPresented: $showingCancelAlert) {
            Button("Ya", role: .destructive) {
                activities = originalActivities
                notes = originalNotes
                editedActivities.removeAll()
                editedNotes.removeAll()
                tempDeletedActivities.removeAll()
                tempDeletedNotes.removeAll()
                dismiss()
            }
            Button("Tidak", role: .cancel) { }
        } message: {
            Text("Apakah Anda yakin ingin membatalkan perubahan?")
        }
    }
    
    private var activitiesForSelectedMonth: [Date: DayItems] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)
        else {
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
            // Only include dates up to today
            if currentDate <= Date() {
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
        
    private func fetchData() async {
        activities = await onFetchActivities(student)
        notes = await onFetchNotes(student)
    }
    
    private func saveChanges() async {
        // Validasi aktivitas
        for (id, (text, status, date)) in editedActivities {
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
            }
        }
        
        // Validasi dan update notes
        for (id, (text, date)) in editedNotes {
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
        editedActivities.removeAll()
        editedNotes.removeAll()
        tempDeletedActivities.removeAll()
        tempDeletedNotes.removeAll()
        
        dismiss()
    }
}
