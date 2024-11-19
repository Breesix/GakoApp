import SwiftUI

class StudentDetailViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var notes: [Note] = []
    @Published var editedActivities: [UUID: (String, Status, Date)] = [:]
    @Published var editedNotes: [UUID: (String, Date)] = [:]
    @Published var selectedDate: Date
    @Published var toast: Toast?
    @Published var isEditingMode: Bool = false
    @Published var showSnapshotPreview: Bool = false
    @Published var currentPageIndex: Int = 0
    @Published var allPageSnapshots: [UIImage] = []
    @Published var noActivityAlertPresented: Bool = false
    @Published var showingCancelAlert: Bool = false
    @Published var isShowingCalendar: Bool = false
    @Published var selectedActivityDate: Date?
    
    // MARK: - Private Properties
    private let calendar = Calendar.current
    private let student: Student
    private var documentInteractionController: UIDocumentInteractionController?
    
    // MARK: - Internal Properties (changed from private)
    let onAddNote: (Note, Student) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onAddActivity: (Activity, Student) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    
    // MARK: - Computed Properties
    var formattedMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: UIConstants.StudentDetailView.localeIdentifier)
        formatter.dateFormat = UIConstants.StudentDetailView.monthFormat
        return formatter.string(from: selectedDate)
    }
    
    var isNextMonthDisabled: Bool {
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let selectedYear = calendar.component(.year, from: selectedDate)
        
        return (selectedYear > currentYear) ||
               (selectedYear == currentYear && selectedMonth >= currentMonth)
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
    func fetchAllData() async {
        await fetchAllNotes()
        await fetchActivities()
    }
    
    func fetchAllNotes() async {
        do {
            let fetchedNotes = await onFetchNotes(student)
            await MainActor.run {
                self.notes = fetchedNotes
            }
        } catch {
            print("Error fetching notes: \(error)")
            await MainActor.run {
                self.notes = []
            }
        }
    }
    
    func fetchActivities() async {
        let fetchActivities = await onFetchActivities(student)
        await MainActor.run {
            activities = fetchActivities
        }
    }
    
    func deleteNote(_ note: Note) async {
        await onDeleteNote(note, student)
        await MainActor.run {
            notes.removeAll(where: { $0.id == note.id })
        }
    }
    
    func deleteActivity(_ activity: Activity) async {
        await onDeleteActivity(activity, student)
        await MainActor.run {
            activities.removeAll(where: { $0.id == activity.id })
        }
        await fetchActivities()
    }
    
    func moveMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    func handleDateSelection(_ date: Date) {
        if activitiesForSelectedMonth[calendar.startOfDay(for: date)] != nil {
            selectedDate = date
        } else {
            if date > Date() {
                noActivityAlertPresented = true
            }
        }
    }
    
    func setupInitialScroll(proxy: ScrollViewProxy) {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        withAnimation(.smooth) {
            proxy.scrollTo(startOfDay, anchor: .top)
        }
    }
    
    func handleDateChange(proxy: ScrollViewProxy) {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        withAnimation(.smooth) {
            proxy.scrollTo(startOfDay, anchor: .top)
        }
    }
    
    func saveChanges() async {
        for (id, (text, status, date)) in editedActivities {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedText.isEmpty {
                await MainActor.run {
                    toast = Toast(style: .error, message: UIConstants.StudentDetailView.emptyActivityMessage)
                }
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
                await MainActor.run {
                    toast = Toast(style: .error, message: UIConstants.StudentDetailView.emptyNoteMessage)
                }
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
        
        await MainActor.run {
            editedActivities.removeAll()
            editedNotes.removeAll()
            
            toast = Toast(style: .success, message: UIConstants.StudentDetailView.saveSuccessMessage)
            isEditingMode = false
        }
    }
    
    func generateSnapshot(for date: Date) {
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
    
    func shareToWhatsApp(images: [UIImage]) {
        guard let firstImage = images.first,
              let imageData = firstImage.pngData() else { return }
        
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("report.jpg")
        try? imageData.write(to: tempFile)
        
        documentInteractionController = UIDocumentInteractionController(url: tempFile)
        documentInteractionController?.uti = "net.whatsapp.image"
        
        // Note: This part might need to be handled in the View layer
        // as it requires UIKit view controller reference
    }
    
    // MARK: - Private Methods
    private func calculateRequiredPages() -> Int {
        let activitiesPages = ceil(Double(max(0, activities.count - 5)) / 10.0)
        let notesPages = ceil(Double(notes.count) / 5.0)
        return 1 + Int(max(activitiesPages, notesPages))
    }
}
