import SwiftUI

struct MonthlyEditView: View {
    let student: Student
    let selectedMonth: Date
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
    @State private var tempEditedActivities: [UUID: (String, Status, Date)] = [:]
    @State private var tempEditedNotes: [UUID: (String, Date)] = [:]
    @State private var showingCancelAlert = false
    @State private var tempDeletedActivities: [Activity] = []
    @State private var tempDeletedNotes: [Note] = []
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(monthYearString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ForEach(Array(activitiesForSelectedMonth.keys.sorted()), id: \.self) { date in
                        if let items = activitiesForSelectedMonth[date] {
                            DayEditCard(
                                date: date,
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
                }
                .padding(.vertical)
                .padding(.bottom, 80) // Add padding for save button
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
        .toolbar(.hidden, for: .bottomBar,.tabBar)
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
            Button("Tidak", role: .cancel) { }
        } message: {
            Text("Apakah Anda yakin ingin membatalkan perubahan?")
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private var activitiesForSelectedMonth: [Date: DayItems] {
        let calendar = Calendar.current
        
        let groupedActivities = Dictionary(grouping: activities) { activity in
            calendar.startOfDay(for: activity.createdAt)
        }
        
        let groupedNotes = Dictionary(grouping: notes) { note in
            calendar.startOfDay(for: note.createdAt)
        }
        
        let allDates = Set(groupedActivities.keys).union(groupedNotes.keys)
        
        var result: [Date: DayItems] = [:]
        
        for date in allDates {
            if calendar.isDate(date, equalTo: selectedMonth, toGranularity: .month) {
                result[date] = DayItems(
                    activities: groupedActivities[date] ?? [],
                    notes: groupedNotes[date] ?? []
                )
            }
        }
        
        return result
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
    
    struct DayEditCard: View {
        let date: Date
        let activities: [Activity]
        let notes: [Note]
        @Binding var editedActivities: [UUID: (String, Status, Date)]
        @Binding var editedNotes: [UUID: (String, Date)]
        let onDeleteActivity: (Activity) -> Void
        let onDeleteNote: (Note) -> Void
        
        @State private var newActivities: [(id: UUID, activity: String, status: Status)] = []
        @State private var newNotes: [(id: UUID, note: String)] = []
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(indonesianFormattedDate(date: date))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.labelPrimaryBlack)
                    
                    Spacer()
                }
                
                if !activities.isEmpty || !newActivities.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AKTIVITAS")
                            .font(.callout)
                            .fontWeight(.bold)
                        ForEach(activities) { activity in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Aktivitas \(activities.firstIndex(of: activity)! + 1)")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(.labelPrimaryBlack)
                                    
                                    Spacer()
                                    
                                    Image("custom.trash.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 34)
                                        .onTapGesture {
                                            onDeleteActivity(activity)
                                        }
                                }
                                HStack {
                                    TextField("Aktivitas", text: makeValueBinding(for: activity))
                                        .font(.body)
                                        .foregroundColor(.labelPrimaryBlack)
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 14)
                                        .background(.cardFieldBG)
                                        .cornerRadius(8)
                                    
                                }
                                StatusPicker(status: makeStatusBinding(for: activity)) { newStatus in
                                    editedActivities[activity.id] = (activity.activity, newStatus, date)
                                }
                            }
                        }
                        ForEach(newActivities, id: \.id) { newActivity in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Aktivitas \(activities.count + newActivities.firstIndex(where: { $0.id == newActivity.id })! + 1)")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .foregroundColor(.labelPrimaryBlack)
                                    
                                    Spacer()
                                    
                                    Image("custom.trash.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 34)
                                        .onTapGesture {
                                            if let index = newActivities.firstIndex(where: { $0.id == newActivity.id }) {
                                                newActivities.remove(at: index)
                                                editedActivities.removeValue(forKey: newActivity.id)
                                            }
                                        }
                                    
                                }
                                HStack {
                                    TextField("Aktivitas", text: Binding(
                                        get: { editedActivities[newActivity.id]?.0 ?? newActivity.activity },
                                        set: { newValue in
                                            let status = editedActivities[newActivity.id]?.1 ?? newActivity.status
                                            editedActivities[newActivity.id] = (newValue, status, date)
                                        }
                                    ))
                                    .font(.body)
                                    .foregroundColor(.labelPrimaryBlack)
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 14)
                                    .background(.cardFieldBG)
                                    .cornerRadius(8)
                                }
                                
                                StatusPicker(status: Binding(
                                    get: { editedActivities[newActivity.id]?.1 ?? newActivity.status },
                                    set: { newValue in
                                        let currentText = editedActivities[newActivity.id]?.0 ?? newActivity.activity
                                        editedActivities[newActivity.id] = (currentText, newValue, date)
                                    }
                                )) { newStatus in
                                    let currentText = editedActivities[newActivity.id]?.0 ?? newActivity.activity
                                    editedActivities[newActivity.id] = (currentText, newStatus, date)
                                }
                            }
                        }
                    }
                } else {
                    Text("Tidak ada aktivitas untuk tanggal ini")
                        .foregroundColor(.labelSecondary)
                }
                
                Button(action: {
                    let newId = UUID()
                    newActivities.append((id: newId, activity: "", status: .tidakMelakukan))
                    editedActivities[newId] = ("", .tidakMelakukan, date)
                }) {
                    Label("Tambah", systemImage: "plus.app.fill")
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundStyle(.buttonPrimaryLabel)
                .background(.buttonOncard)
                .cornerRadius(8)
                
                Divider()
                    .frame(height: 1)
                    .background(.tabbarInactiveLabel)
                    .padding(.vertical, 8)
                
                if !notes.isEmpty || !newNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("CATATAN")
                            .font(.callout)
                            .fontWeight(.bold)
                        ForEach(notes) { note in
                            HStack {
                                TextField("Catatan", text: makeNoteBinding(for: note))
                                    .font(.body)
                                    .foregroundColor(.labelPrimaryBlack)
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 14)
                                    .background(.cardFieldBG)
                                    .cornerRadius(8)
                                
                                Button(action: { onDeleteNote(note) }) {
                                    Image("custom.trash.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 34)
                                }
                            }
                        }
                        ForEach(newNotes, id: \.id) { newNote in
                            HStack {
                                TextField("Catatan", text: Binding(
                                    get: { editedNotes[newNote.id]?.0 ?? newNote.note },
                                    set: { editedNotes[newNote.id] = ($0, date) }
                                ))
                                .font(.body)
                                .foregroundColor(.labelPrimaryBlack)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 14)
                                .background(.cardFieldBG)
                                .cornerRadius(8)
                                
                                Button(action: {
                                    if let index = newNotes.firstIndex(where: { $0.id == newNote.id }) {
                                        newNotes.remove(at: index)
                                        editedNotes.removeValue(forKey: newNote.id)
                                    }
                                }) {
                                    Image("custom.trash.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 34)
                                }
                            }
                        }
                    }
                } else {
                    Text("Tidak ada catatan untuk tanggal ini")
                        .foregroundColor(.labelSecondary)
                }
                
                Button(action: {
                    let newId = UUID()
                    newNotes.append((id: newId, note: ""))
                    editedNotes[newId] = ("", date)
                }) {
                    Label("Tambah", systemImage: "plus.app.fill")
                }
                .padding(.vertical, 7)
                .padding(.horizontal, 14)
                .font(.footnote)
                .fontWeight(.regular)
                .foregroundStyle(.buttonPrimaryLabel)
                .background(.buttonOncard)
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.white)
            .cornerRadius(20)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        
        private func indonesianFormattedDate(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "id_ID")
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
        
        private func makeValueBinding(for activity: Activity) -> Binding<String> {
            Binding(
                get: { editedActivities[activity.id]?.0 ?? activity.activity },
                set: { newValue in
                    let status = editedActivities[activity.id]?.1 ?? activity.status
                    editedActivities[activity.id] = (newValue, status, date)
                }
            )
        }
        
        private func makeStatusBinding(for activity: Activity) -> Binding<Status> {
            Binding(
                get: { editedActivities[activity.id]?.1 ?? activity.status },
                set: { newValue in
                    let text = editedActivities[activity.id]?.0 ?? activity.activity
                    editedActivities[activity.id] = (text, newValue, date)
                }
            )
        }
        
        private func makeNoteBinding(for note: Note) -> Binding<String> {
            Binding(
                get: { editedNotes[note.id]?.0 ?? note.note },
                set: { editedNotes[note.id] = ($0, date) }
            )
        }
    }
}

