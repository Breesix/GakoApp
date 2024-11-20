//
//  DailyReportViewModel.swift
//  Gako
//
//  Created by Akmal Hakim on 19/11/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: ViewModel for handling DailyReport business logic and state management
//

import SwiftUI

@MainActor
final class DailyReportViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var showingCancelAlert = false
    @Published var notes: [Note] = []
    @Published var selectedDate: Date
    @Published var noteToEdit: Note?
    @Published var activityToEdit: Activity?
    @Published var isAddingNewNote = false
    @Published var isAddingNewActivity = false
    @Published var activities: [Activity] = []
    @Published var isShowingCalendar: Bool = false
    @Published var noActivityAlertPresented = false
    @Published var showSnapshotPreview = false
    @Published var snapshotImage: UIImage?
    @Published var toast: Toast?
    @Published var isEditing = false
    @Published var isEditingMode = false
    @Published var editedActivities: [UUID: (String, Status, Date)] = [:]
    @Published var editedNotes: [UUID: (String, Date)] = [:]
    @Published var showEmptyAlert = false
    @Published var emptyAlertMessage = ""
    @Published var currentPageIndex: Int = 0
    @Published var allPageSnapshots: [UIImage] = []
    
    // MARK: - Properties
    let student: Student
    let calendar = Calendar.current
    private var documentInteractionController: UIDocumentInteractionController?
    
    // MARK: - Callback Properties
    let onAddNote: (Note, Student) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onAddActivity: (Activity, Student) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    
    // MARK: - Computed Properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var activitiesForSelectedDay: [Date: DayItems] {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        let dayActivities = activities.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
        
        let dayNotes = notes.filter {
            calendar.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
        
        return [startOfDay: DayItems(activities: dayActivities, notes: dayNotes)]
    }
    
    var activitiesForSelectedMonth: [Date: DayItems] {
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
    
    // MARK: - Initialization
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
        self.selectedDate = initialDate
        self.onAddNote = onAddNote
        self.onUpdateNote = onUpdateNote
        self.onDeleteNote = onDeleteNote
        self.onAddActivity = onAddActivity
        self.onDeleteActivity = onDeleteActivity
        self.onUpdateActivityStatus = onUpdateActivityStatus
        self.onFetchNotes = onFetchNotes
        self.onFetchActivities = onFetchActivities
    }
    
    // MARK: - Public Methods
    func validateAndShare() {
        if let dayItems = activitiesForSelectedDay[calendar.startOfDay(for: selectedDate)] {
            if dayItems.activities.isEmpty && dayItems.notes.isEmpty {
                emptyAlertMessage = "Tidak ada catatan dan aktivitas yang bisa dibagikan"
                showEmptyAlert = true
                return
            }
            
            generateSnapshot(for: selectedDate)
            withAnimation {
                showSnapshotPreview = true
            }
        } else {
            emptyAlertMessage = "Tidak ada catatan dan aktivitas yang bisa dibagikan"
            showEmptyAlert = true
        }
    }
    
    func moveDay(by value: Int) {
        if let newDate = calendar.date(byAdding: .day, value: value, to: selectedDate) {
            if newDate <= Date() {
                selectedDate = newDate
            }
        }
    }
    
    func deleteNote(_ note: Note) {
        Task {
            await onDeleteNote(note, student)
            notes.removeAll(where: { $0.id == note.id })
        }
    }
    
    func deleteActivity(_ activity: Activity) {
        Task {
            await onDeleteActivity(activity, student)
            activities.removeAll(where: { $0.id == activity.id })
            await fetchActivities()
        }
    }
    
    func fetchInitialData() async {
        await fetchAllNotes()
        await fetchActivities()
    }
    
    func saveChanges() async {
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
        
        await fetchInitialData()
        editedActivities.removeAll()
        editedNotes.removeAll()
        toast = Toast(style: .success, message: "Perubahan berhasil disimpan")
    }
    
    func shareToWhatsApp(images: [UIImage]) {
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
    
    func showShareSheet(images: [UIImage]) {
        let activityVC = UIActivityViewController(
            activityItems: images,
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
    
    // MARK: - Private Methods
    private func fetchAllNotes() async {
        notes = await onFetchNotes(student)
    }
    
    private func fetchActivities() async {
        activities = await onFetchActivities(student)
    }
    
    func generateSnapshot(for date: Date) {
        let reportView = DailyReportTemplate(
            student: student,
            activities: activitiesForSelectedDay[calendar.startOfDay(for: date)]?.activities ?? [],
            notes: activitiesForSelectedDay[calendar.startOfDay(for: date)]?.notes ?? [],
            date: date
        )
        
        let totalPages = reportView.calculateRequiredPages()
        var snapshots: [UIImage] = []
        
        for pageIndex in 0..<totalPages {
            let pageView = reportView.reportPage(pageIndex: pageIndex)
                .frame(width: reportView.a4Width, height: reportView.a4Height)
                .background(.white)
            
            if let pageSnapshot = pageView.snapshot() {
                snapshots.append(pageSnapshot)
            }
        }
        
        allPageSnapshots = snapshots
        currentPageIndex = 0
        showSnapshotPreview = true
    }
}
