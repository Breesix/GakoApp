//
//  StudentDetailView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

struct StudentDetailView: View {
    let student: Student
    let onAddStudent: (Student) async -> Void
    let onUpdateStudent: (Student) async -> Void
    let onAddNote: (Note, Student) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onAddActivity: (Activity, Student) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onUpdateActivityStatus: (Activity, Bool?) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    let onCheckNickname: (String, UUID?) -> Bool
    let compressedImageData: Data?
    
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
    @State private var isTabBarHidden = true
    @State private var showSnapshotPreview = false
    @State private var snapshotImage: UIImage?
    @State private var documentInteractionController: UIDocumentInteractionController?
    @State private var selectedActivityDate: Date?
    @State private var newStudentImage: UIImage?
    
    private let calendar = Calendar.current
    @Environment(\.presentationMode) var presentationMode
    
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
            // For iPad
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
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                Text("Kembali")
                                    .foregroundStyle(.white)
                                    .fontWeight(.regular)
                            }
                            .font(.body)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Edit Profil")
                                .foregroundStyle(.white)
                                .font(.subheadline)
                                .fontWeight(.regular)
                        }
                    }
                    .padding(14)
                }
                .frame(height: 58)
                
                ProfileHeader(student: student)
                    .padding(16)
                
                Divider()
                
                VStack(spacing: 0) {
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
                                    .foregroundStyle(.buttonLinkOnSheet)
                            }
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
                        ScrollViewReader { scrollProxy in
                            ScrollView {
                                LazyVStack(spacing: 0) {
                                    ForEach(Array(activitiesForSelectedMonth.keys.sorted()), id: \.self) { day in
                                        if let dayItems = activitiesForSelectedMonth[day] {
                                            DailyReportCard(
                                                activities: dayItems.activities,
                                                notes: dayItems.notes,
                                                student: student,
                                                date: day,
                                                onAddNote: { selectedDate = day
                                                    isAddingNewNote = true },
                                                onAddActivity: { selectedDate = day
                                                    isAddingNewActivity = true },
                                                onDeleteActivity: deleteActivity,
                                                onEditNote: { self.selectedNote = $0 },
                                                onDeleteNote: deleteNote,
                                                onShareTapped: { date in
                                                    let reportView = DailyReportTemplate(
                                                        student: student,
                                                        activities: dayItems.activities,
                                                        notes: dayItems.notes,
                                                        date: date
                                                    )
                                                    let image = reportView.snapshot()
                                                    showShareSheet(image: image)
                                                },
                                                onUpdateActivityStatus: { activity, newStatus in
                                                    await onUpdateActivityStatus(activity, newStatus)
                                                }
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.bottom, 12)
                                            .id(day)
                                        }
                                    }
                                }
                            }
                            .onChange(of: selectedDate) {
                                let startOfDay = calendar.startOfDay(for: selectedDate)
                                if let dayItems = activitiesForSelectedMonth[startOfDay] {
                                    if dayItems.activities.isEmpty && dayItems.notes.isEmpty && selectedDate > Date() {
                                        noActivityAlertPresented = true
                                    } else {
                                        withAnimation(.smooth) {
                                            scrollProxy.scrollTo(startOfDay, anchor: .top)
                                        }
                                        isShowingCalendar = false
                                    }
                                } else {
                                    noActivityAlertPresented = true
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .hideTabBar()
        .sheet(isPresented: $isEditing) {
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
        .sheet(item: $selectedNote) { note in
            ManageNoteView(
                mode: .edit(note),
                student: student,
                selectedDate: selectedDate,
                onDismiss: { selectedNote = nil },
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
            AddActivityView(
                student: student,
                selectedDate: selectedDate,
                onDismiss: {
                    isAddingNewActivity = false
                    Task {
                        await fetchActivities()
                    }
                },
                onSave: { activity in
                    await onAddActivity(activity, student)
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
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
    
    private func generateSnapshot(for date: Date) {
        let reportView = DailyReportTemplate(
            student: student,
            activities: activitiesForSelectedMonth[date]?.activities ?? [],
            notes: activitiesForSelectedMonth[date]?.notes ?? [],
            date: date
        )
        snapshotImage = reportView.snapshot()
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

#Preview {
    StudentDetailView(
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        onAddStudent: { _ in print("added student") },
        onUpdateStudent: { _ in print("updated student") },
        onAddNote: { _, _ in print("added note") },
        onUpdateNote: { _ in print("updated note") },
        onDeleteNote: { _, _ in print("deleted note") },
        onAddActivity: { _, _ in print("added activity") },
        onDeleteActivity: { _, _ in print("deleted activity") },
        onUpdateActivityStatus: { _, _ in print("updated activity status") },
        onFetchNotes: { _ in return [] },
        onFetchActivities: { _ in return [] },
        onCheckNickname: { _, _ in return false },
        compressedImageData: nil
    )
}
