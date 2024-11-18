//
//  StudentDetailView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI
import PhotosUI

struct StudentDetailView: View {
    let student: Student
    let onAddStudent: (Student) async -> Void
    let onUpdateStudent: (Student) async -> Void
    let onAddNote: (Note, Student) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onAddActivity: (Activity, Student) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    let onCheckNickname: (String, UUID?) -> Bool
    let compressedImageData: Data?
    
    @State private var editedActivities: [UUID: (String, Status, Date)] = [:]
    @State private var editedNotes: [UUID: (String, Date)] = [:]
    @State private var selectedStudent: Student?
    @State private var showingAddActivity = false
    @State private var activityToEdit: Activity?
    @State private var noteToEdit: Note?

    @State private var currentPageIndex: Int = 0
    @State private var allPageSnapshots: [UIImage] = []
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
    @State private var showingCancelAlert = false
    @State private var isTabBarHidden = true
    @State private var showSnapshotPreview = false
    @State private var snapshotImage: UIImage?
    @State private var documentInteractionController: UIDocumentInteractionController?
    @State private var selectedActivityDate: Date?
    @State private var newStudentImage: UIImage?
    @State private var isEditingMode = false

    private let calendar = Calendar.current
    @Environment(\.presentationMode) var presentationMode
    
    @State private var toast: Toast?
    let initialScrollDate: Date
    
    @State private var isEditingMonthly = false

    private func shareToWhatsApp(images: [UIImage]) {
        // WhatsApp hanya bisa share satu gambar, jadi kita ambil halaman pertama
        guard let firstImage = images.first,
              let imageData = firstImage.pngData() else { return }
        
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

    private func showShareSheet(images: [UIImage]) {
        let activityVC = UIActivityViewController(
            activityItems: images, // Share semua halaman
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
                            !isEditingMode ? presentationMode.wrappedValue.dismiss() : (showingCancelAlert = true)
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Text(!isEditingMode ? student.nickname : "Batal")
                                    .foregroundStyle(.white)
                                    .font(.body)
                                    .fontWeight(.regular)
                            }
                            .font(.body)
                        }
                        
                        Spacer()
                        
                        if !isEditingMode {
                            Button {
                                isEditingMode = true
                            } label: {
                                Text("Edit Dokumen")
                                    .foregroundStyle(.white)
                                    .font(.body)
                                    .fontWeight(.regular)
                            }
                        }
                    }
                    .padding(14)
                }
                .frame(height: 58)
                
                VStack(spacing: 0) {
                    // MARK: this is a month mover
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
                                    .foregroundStyle(isNextMonthDisabled ? .gray : .buttonLinkOnSheet)
                            }
                            .disabled(isNextMonthDisabled)
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
                        // Replace the ScrollView content with:
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    if isEditingMode {
                                        // Edit mode content
                                        ForEach(Array(activitiesForSelectedMonth.keys.sorted()), id: \.self) { day in
                                            if let dayItems = activitiesForSelectedMonth[day] {
                                                MonthlyEditCard(
                                                    date: day,
                                                    activities: dayItems.activities,
                                                    notes: dayItems.notes,
                                                    student: student,
                                                    selectedStudent: $selectedStudent,
                                                    isAddingNewActivity: $isAddingNewActivity,
                                                    editedActivities: $editedActivities,
                                                    editedNotes: $editedNotes,
                                                    onDeleteActivity: deleteActivity,
                                                    onDeleteNote: deleteNote,
                                                    onActivityUpdate: { activity in
                                                        activityToEdit = activity
                                                    },
                                                    onAddActivity: {
                                                        selectedDate = day
                                                        isAddingNewActivity = true
                                                    },
                                                    onUpdateActivityStatus: onUpdateActivityStatus,
                                                    onEditNote: { note in
                                                        noteToEdit = note
                                                    },
                                                    onAddNote: { _ in
                                                        selectedDate = day
                                                        isAddingNewNote = true
                                                    }
                                                )
                                                .padding(.horizontal, 16)
                                                .padding(.bottom, 12)
                                            }
                                        }
                                    } else {
                                        // Normal view content
                                        ForEach(Array(activitiesForSelectedMonth.keys.sorted()), id: \.self) { day in
                                            if let dayItems = activitiesForSelectedMonth[day] {
                                                DailyReportCard(
                                                    activities: dayItems.activities,
                                                    notes: dayItems.notes,
                                                    student: student,
                                                    date: day,
                                                    onAddNote: { selectedDate = day; isAddingNewNote = true },
                                                    onAddActivity: { selectedDate = day; isAddingNewActivity = true },
                                                    onDeleteActivity: deleteActivity,
                                                    onEditNote: { self.selectedNote = $0 },
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
                                .task {
                                    let startOfDay = calendar.startOfDay(for: initialScrollDate)
                                    selectedDate = initialScrollDate
                                    withAnimation(.smooth) {
                                        scrollProxy.scrollTo(startOfDay, anchor: .top)
                                    }
                                }
                            }
                            .onChange(of: selectedDate) {
                                let startOfDay = calendar.startOfDay(for: selectedDate)
                                withAnimation(.smooth) {
                                    scrollProxy.scrollTo(startOfDay, anchor: .top)
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
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .hideTabBar()
            
            // MARK: THIS IS VIEW FOR SNAPSHOTS PREVIEW
            if showSnapshotPreview {
                SnapshotPreview(
                    images: allPageSnapshots, currentPageIndex: $currentPageIndex,
                    showSnapshotPreview: $showSnapshotPreview,
                    toast: $toast,
                    shareToWhatsApp: shareToWhatsApp,
                    showShareSheet: showShareSheet
                )
            }
        }
        .tint(.accent)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .hideTabBar()
        .sheet(item: $noteToEdit) { note in
            ManageNoteView(
                mode: .edit(note),
                student: student,
                selectedDate: selectedDate,
                onDismiss: {
                    noteToEdit = nil
                },
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
        .sheet(isPresented: $isAddingNewActivity) {
            ManageActivityView(
                mode: .add,
                student: student,
                selectedDate: selectedDate,
                onDismiss: { isAddingNewActivity = false },
                onSave: { newActivity in
                    Task {
                        await onAddActivity(newActivity, student)
                        await fetchActivities()
                    }
                },
                onUpdate: { _ in }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }

        .sheet(item: $activityToEdit) { activity in
            ManageActivityView(
                mode: .edit(activity),
                student: student,
                selectedDate: selectedDate,
                onDismiss: { activityToEdit = nil },
                onSave: { _ in },
                onUpdate: { updatedActivity in
                    Task {
                        await onUpdateActivityStatus(updatedActivity, updatedActivity.status)
                        await fetchActivities()
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }        .sheet(isPresented: $isEditing) {
            ManageStudentView(
                mode: .edit(student),
                compressedImageData: compressedImageData,
                newStudentImage: newStudentImage,
                onSave: onAddStudent,
                onUpdate: onUpdateStudent,
                onImageChange: { image in
                    newStudentImage = image
                },
                checkNickname: onCheckNickname
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
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

        .task {
            await fetchAllNotes()
            await fetchActivities()
        }
    }
    
    private var isNextMonthDisabled: Bool {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let selectedYear = calendar.component(.year, from: selectedDate)
        
        return (selectedYear > currentYear) ||
               (selectedYear == currentYear && selectedMonth >= currentMonth)
    }

    
    private func generateSnapshot(for date: Date) {
        let reportView = DailyReportTemplate(
            student: student,
            activities: activitiesForSelectedMonth[calendar.startOfDay(for: date)]?.activities ?? [],
            notes: activitiesForSelectedMonth[calendar.startOfDay(for: date)]?.notes ?? [],
            date: date
        )
        
        let totalPages = calculateRequiredPages()
        var snapshots: [UIImage] = []
        
        for pageIndex in 0..<totalPages {
            let pageView = reportView.reportPage(pageIndex: pageIndex)
                .frame(width: reportView.a4Width, height: reportView.a4Height)
                .background(.white)
            
            if let snapshot = SnapshotHelper.shared.generateSnapshot(
                from: pageView,
                size: CGSize(width: reportView.a4Width, height: reportView.a4Height)
            ) {
                snapshots.append(snapshot)
            }
        }
        
        if !snapshots.isEmpty {
            allPageSnapshots = snapshots
            currentPageIndex = 0
            showSnapshotPreview = true
        }
    }
    
    private func calculateRequiredPages() -> Int {
       let activitiesPages = ceil(Double(max(0, activities.count - 5)) / 10.0)
       let notesPages = ceil(Double(notes.count) / 5.0)
       return 1 + Int(max(activitiesPages, notesPages))
   }
    
    private var activityThatDay: [Activity] {
        activities.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
    }
    
    private var filteredNotes: [Note] {
        notes.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
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
    
    private func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
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
    
    private func saveChanges() async {
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

        await fetchAllNotes()
        await fetchActivities()
        
        editedActivities.removeAll()
        editedNotes.removeAll()
        
        toast = Toast(style: .success, message: "Perubahan berhasil disimpan")
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
        }
    }
}

struct ShareButtonView: View {
    let iconName: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            if iconName == "whatsapp" {
                Image("whatsapp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: iconName)
                    .font(.system(size: 24))
            }
            Text(title)
                .font(.caption)
        }
        .foregroundColor(color)
    }
}
