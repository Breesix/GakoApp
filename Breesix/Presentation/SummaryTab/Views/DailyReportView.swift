//
//  DailyReportView.swift
//  Breesix
//
//  Created by Rangga Biner on 08/11/24.
//

import SwiftUI

struct DailyReportView: View {
    let student: Student
    let initialDate: Date
    let onAddNote: (Note, Student) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onAddActivity: (Activity, Student) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    
    @State private var showingCancelAlert = false
    @State private var notes: [Note] = []
    @State private var selectedDate: Date
    @State private var noteToEdit: Note?
    @State private var activityToEdit: Activity?
    @State private var isAddingNewNote = false
    @State private var isAddingNewActivity = false
    @State private var activities: [Activity] = []
    @State private var isShowingCalendar: Bool = false
    @State private var noActivityAlertPresented = false
    @State private var showSnapshotPreview = false
    @State private var snapshotImage: UIImage?
    @State private var documentInteractionController: UIDocumentInteractionController?
    @State private var selectedActivityDate: Date?
    @State private var toast: Toast?
    @State private var isEditing = false
    @State private var isEditingMode = false
    @Environment(\.presentationMode) private var presentationMode
    @State private var editedActivities: [UUID: (String, Status, Date)] = [:]
    @State private var editedNotes: [UUID: (String, Date)] = [:]
    
    private let calendar = Calendar.current
        
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    
    init(student: Student,
         initialDate: Date,
         onAddNote: @escaping (Note, Student) async -> Void,
         onUpdateNote: @escaping (Note) async -> Void,
         onDeleteNote: @escaping (Note, Student) async -> Void,
         onAddActivity: @escaping (Activity, Student) async -> Void,
         onDeleteActivity: @escaping (Activity, Student) async -> Void,
         onUpdateActivityStatus: @escaping (Activity, Status) async -> Void,
         onFetchNotes: @escaping (Student) async -> [Note],
         onFetchActivities: @escaping (Student) async -> [Activity]) {
        self.student = student
        self.initialDate = initialDate
        self.onAddNote = onAddNote
        self.onUpdateNote = onUpdateNote
        self.onDeleteNote = onDeleteNote
        self.onAddActivity = onAddActivity
        self.onDeleteActivity = onDeleteActivity
        self.onUpdateActivityStatus = onUpdateActivityStatus
        self.onFetchNotes = onFetchNotes
        self.onFetchActivities = onFetchActivities
        _selectedDate = State(initialValue: initialDate)
    }

    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    Color(.bgSecondary)
                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(edges: .top)
                    
                    ZStack {
                        HStack(spacing: 0) {
                            Button {
                                !isEditingMode ? presentationMode.wrappedValue.dismiss() : (showingCancelAlert = true)
                            } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Text(!isEditingMode ? "Ringkasan" : student.nickname)
                                        .foregroundStyle(.white)
                                        .fontWeight(.regular)
                                }
                                .font(.body)
                            }   
                            
                            Spacer()
                            
                            if !isEditingMode {
                                Button {
                                    isEditingMode = true
                                } label: {
                                    Text("Edit")
                                        .foregroundStyle(.white)
                                        .fontWeight(.regular)
                                }
                            }
                            
                        }
                        .padding(.horizontal, 14)
                        
                        Text(!isEditingMode ? student.nickname : formattedDate)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 58)
                
                VStack(spacing: 0) {
                    HStack {
                        Text(formattedDate)
                            .fontWeight(.semibold)
                            .foregroundColor(.labelPrimaryBlack)
                        
                        HStack(spacing: 8) {
                            Button(action: { moveDay(by: -1) }) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.buttonLinkOnSheet)
                            }
                            
                            Button(action: { moveDay(by: 1) }) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(calendar.isDateInToday(selectedDate) ? .gray : .buttonLinkOnSheet)
                            }
                            .disabled(calendar.isDateInToday(selectedDate))
                        }
                        
                        Spacer()
                        
                        CalendarButton(
                            selectedDate: $selectedDate,
                            isShowingCalendar: $isShowingCalendar,
                            onDateSelected: { newDate in
                                if activitiesForSelectedDay[calendar.startOfDay(for: newDate)] != nil {
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
                    
                    if activitiesForSelectedDay.isEmpty {
                        VStack {
                            Spacer()
                            EmptyState(message: "Belum ada aktivitas yang tercatat.")
                            Spacer()
                        }
                    } else {
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    if isEditingMode {
                                        // Edit mode content
                                        if let dayItems = activitiesForSelectedDay[calendar.startOfDay(for: selectedDate)] {
                                            DailyEditCard(
                                                date: selectedDate,
                                                activities: dayItems.activities,
                                                notes: dayItems.notes,
                                                student: student,
                                                selectedStudent: .constant(nil),
                                                isAddingNewActivity: $isAddingNewActivity,
                                                editedActivities: $editedActivities,
                                                editedNotes: $editedNotes,
                                                onDeleteActivity: deleteActivity,
                                                onDeleteNote: deleteNote,
                                                onActivityUpdate: { activity in
                                                    activityToEdit = activity
                                                },
                                                onAddActivity: {
                                                    isAddingNewActivity = true
                                                },
                                                onUpdateActivityStatus: onUpdateActivityStatus,
                                                onEditNote: { note in
                                                    noteToEdit = note
                                                },
                                                onAddNote: { _ in
                                                    isAddingNewNote = true
                                                }
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 12)
                                        }
                                    } else {
                                        // Normal view content
                                        if let dayItems = activitiesForSelectedDay[calendar.startOfDay(for: selectedDate)] {
                                            StudentDailyReportCard(
                                                activities: dayItems.activities,
                                                notes: dayItems.notes,
                                                student: student,
                                                date: selectedDate,
                                                onAddNote: { isAddingNewNote = true },
                                                onAddActivity: { isAddingNewActivity = true },
                                                onDeleteActivity: deleteActivity,
                                                onEditNote: { self.noteToEdit = $0 },
                                                onDeleteNote: deleteNote,
                                                onShareTapped: { date in
                                                    selectedActivityDate = date
                                                    generateSnapshot(for: date)
                                                    withAnimation {
                                                        showSnapshotPreview = true
                                                    }
                                                },
                                                onUpdateActivityStatus: { activity, newStatus in
                                                    await onUpdateActivityStatus(activity, newStatus)
                                                }
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 12)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if isEditingMode {
                        VStack {
                            Button {
                                Task {
                                    await saveChanges()
                                    isEditingMode = false
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
                            .padding(.vertical, 12)
                        }
                        .background(Color.bgMain)
                    } else {
                        Button {
                            generateSnapshot(for: selectedDate)
                            withAnimation {
                                showSnapshotPreview = true
                            }
                        } label: {
                            Text("Bagikan Dokumentasi")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(.labelPrimaryBlack)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(.orangeClickAble))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    }
                }
            }
            
            if showSnapshotPreview, let image = snapshotImage {
                SnapshotPreviewOverlay(
                    image: image,
                    showSnapshotPreview: $showSnapshotPreview,
                    toast: $toast,
                    shareToWhatsApp: shareToWhatsApp,
                    showShareSheet: showShareSheet
                )
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .hideTabBar()
        .toastView(toast: $toast)
        .alert("No Activity", isPresented: $noActivityAlertPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("There are no activities recorded for the selected date.")
        }
        .alert("Peringatan", isPresented: $showingCancelAlert) {
                Button("Ya", role: .destructive) {
                    isEditingMode = false
                }
                Button("Tidak", role: .cancel) { }
            } message: {
                Text("Apakah Anda yakin ingin membatalkan perubahan?")
            }
        .sheet(isPresented: $isAddingNewActivity) {
            ManageActivityView(
                mode: .add(student, selectedDate),
                onSave: { newActivity in
                    Task {
                        await onAddActivity(newActivity, student)
                        await fetchActivities()
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
                        await onUpdateActivityStatus(updatedActivity, updatedActivity.status)
                        await fetchActivities()
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }

        .sheet(item: $noteToEdit) { note in
            ManageNoteView(
                mode: .edit(note),
                student: student,
                selectedDate: selectedDate,
                onDismiss: { noteToEdit = nil },
                onSave: { note in
                    await onAddNote(note, student)
                },
                onUpdate: { updatedNote in
                    Task {
                        await onUpdateNote(updatedNote)
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .sheet(isPresented: $isAddingNewNote) {
            ManageNoteView(
                mode: .add,
                student: student,
                selectedDate: selectedDate,
                onDismiss: {
                    isAddingNewNote = false
                    Task {
                        await fetchAllNotes()
                    }
                },
                onSave: { note in
                    await onAddNote(note, student)
                },
                onUpdate: { _ in }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
        .task {
            await fetchAllNotes()
            await fetchActivities()
        }
    }
    
    private func saveChanges() async {
        // Validate activities
        for (id, (text, status, date)) in editedActivities {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                toast = Toast(style: .error, message: "Aktivitas tidak boleh kosong")
                return
            }
            if let activity = activities.first(where: { $0.id == id }) {
                var updatedActivity = activity
                updatedActivity.activity = trimmedText
                updatedActivity.status = status
                await onUpdateActivityStatus(updatedActivity, status)
            }
        }

        // Validate notes
        for (id, (text, date)) in editedNotes {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                toast = Toast(style: .error, message: "Catatan tidak boleh kosong")
                return
            }
            if let note = notes.first(where: { $0.id == id }) {
                var updatedNote = note
                updatedNote.note = trimmedText
                await onUpdateNote(updatedNote)
            }
        }

        // Refresh data
        await fetchAllNotes()
        await fetchActivities()
        
        // Clear temporary changes
        editedActivities.removeAll()
        editedNotes.removeAll()
        
        // Show success message
        toast = Toast(style: .success, message: "Perubahan berhasil disimpan")
    }
    // MARK: - Helper Methods
    
    private func generateSnapshot(for date: Date) {
        let reportView = DailyReportTemplate(
            student: student,
            activities: activitiesForSelectedDay[calendar.startOfDay(for: date)]?.activities ?? [],
            notes: activitiesForSelectedDay[calendar.startOfDay(for: date)]?.notes ?? [],
            date: date
        )
        snapshotImage = reportView.snapshot()
    }
    
    private func fetchAllNotes() async {
        notes = await onFetchNotes(student)
    }
    
    private func fetchActivities() async {
        activities = await onFetchActivities(student)
    }
    
    private func deleteNote(_ note: Note) {
        Task {
            await onDeleteNote(note, student)
            notes.removeAll(where: { $0.id == note.id })
        }
    }
    
    private func deleteActivity(_ activity: Activity) {
        Task {
            await onDeleteActivity(activity, student)
            activities.removeAll(where: { $0.id == activity.id })
            await fetchActivities()
        }
    }
    
    private func moveDay(by value: Int) {
        if let newDate = calendar.date(byAdding: .day, value: value, to: selectedDate) {
            if newDate <= Date() {
                selectedDate = newDate
            }
        }
    }
    
    private func shareToWhatsApp(image: UIImage) {
        guard let imageData = image.pngData() else { return }
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("report.jpg")
        try? imageData.write(to: tempFile)
        
        documentInteractionController = UIDocumentInteractionController(url: tempFile)
        documentInteractionController?.uti = "net.whatsapp.image"
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            documentInteractionController?.presentOpenInMenu(
                from: CGRect.zero,
                in: rootVC.view,
                animated: true
            )
        }
    }
    
    private func showShareSheet(image: UIImage) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.frame.width / 2, y: window.frame.height / 2, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private var activitiesForSelectedDay: [Date: DayItems] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        let dayActivities = activities.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
        
        let dayNotes = notes.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
        
        return [startOfDay: DayItems(activities: dayActivities, notes: dayNotes)]
    }
    
    private var activitiesForSelectedMonth: [Date: DayItems] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
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
}

// MARK: - Supporting Views

struct SnapshotPreviewOverlay: View {
    let image: UIImage
    @Binding var showSnapshotPreview: Bool
    @Binding var toast: Toast?
    let shareToWhatsApp: (UIImage) -> Void
    let showShareSheet: (UIImage) -> Void
    
    var body: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .transition(.opacity)
            .onTapGesture {
                withAnimation {
                    showSnapshotPreview = false
                }
            }
        
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                .padding(.horizontal)
                .padding(.top, 72)
            
            Spacer()
            
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                
                HStack(spacing: 20) {
                    ShareButton(
                        title: "WhatsApp",
                        icon: "square.and.arrow.up",
                        color: .green
                    ) {
                        shareToWhatsApp(image)
                    }
                    
                    ShareButton(
                        title: "Save",
                        icon: "square.and.arrow.down",
                        color: .blue
                    ) {
                        let imageSaver = ImageSaver()
                        imageSaver.writeToPhotoAlbum(image: image)
                        toast = Toast(
                            style: .success,
                            message: "Image saved to photo library",
                            duration: 2,
                            width: 280
                        )
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showSnapshotPreview = false
                        }
                    }
                    
                    ShareButton(
                        title: "Share",
                        icon: "square.and.arrow.up",
                        color: .orange
                    ) {
                        showShareSheet(image)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }
        .transition(.move(edge: .bottom))
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    DailyReportView(
        student: Student(
            fullname: "John Doe",
            nickname: "John"
        ), initialDate: Date(),
        onAddNote: { _, _ in },
        onUpdateNote: { _ in },
        onDeleteNote: { _, _ in },
        onAddActivity: { _, _ in },
        onDeleteActivity: { _, _ in },
        onUpdateActivityStatus: { _, _ in },
        onFetchNotes: { _ in return [] },
        onFetchActivities: { _ in return [] }
    )
}
