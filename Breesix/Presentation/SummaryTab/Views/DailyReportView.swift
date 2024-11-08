//
//  DailyReportView.swift
//  Breesix
//
//  Created by Rangga Biner on 08/11/24.
//

import SwiftUI

struct DailyReportView: View {
    let student: Student
    let onAddNote: (Note, Student) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onAddActivity: (Activity, Student) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    
    @State private var notes: [Note] = []
    @State private var selectedDate = Date()
    @State private var selectedNote: Note?
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
    @Environment(\.presentationMode) private var presentationMode
    
    private let calendar = Calendar.current
        
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                ZStack {
                    Color(.bgSecondary)
                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(edges: .top)
                    
                    ZStack {
                        HStack(spacing: 0) {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack(spacing: 3) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                    Text("Ringkasan")
                                        .foregroundStyle(.white)
                                        .fontWeight(.regular)
                                }
                                .font(.body)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                isEditing = true
                            }) {
                                Text("Edit")
                                    .foregroundStyle(.white)
                                    .fontWeight(.regular)
                            }
                        }
                        .padding(.horizontal, 14)
                        
                        Text(student.fullname)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .frame(height: 58)
                
                // Calendar Header
                VStack(spacing: 0) {
                    HStack {
                        Text(formattedDate)
                            .fontWeight(.semibold)
                            .foregroundColor(.labelPrimaryBlack)
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                moveDay(by: -1)
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundStyle(.buttonLinkOnSheet)
                            }
                            
                            Button(action: {
                                moveDay(by: 1)
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.buttonLinkOnSheet)
                            }
                        }
                        
                        Spacer()
                        
                        CalendarButton(
                            selectedDate: $selectedDate,
                            isShowingCalendar: $isShowingCalendar,
                            onDateSelected: { newDate in
                                if activitiesForSelectedDay[calendar.startOfDay(for: newDate)] != nil {
                                    // Has activities
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
                    
                    // Activities List
                    if activitiesForSelectedDay.isEmpty {
                        VStack {
                            Spacer()
                            EmptyState(message: "Belum ada aktivitas yang tercatat.")
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                if let dayItems = activitiesForSelectedDay[calendar.startOfDay(for: selectedDate)] {
                                    DailyReportCard(
                                        activities: dayItems.activities,
                                        notes: dayItems.notes,
                                        student: student,
                                        date: selectedDate,
                                        onAddNote: {
                                            isAddingNewNote = true
                                        },
                                        onAddActivity: {
                                            isAddingNewActivity = true
                                        },
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
                }
            }
            
            // Snapshot Preview
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
        .task {
            await fetchAllNotes()
            await fetchActivities()
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
    }
    
    // MARK: - Helper Methods
    
    private func generateSnapshot(for date: Date) {
        let reportView = DailyReportTemplate(
            student: student,
            activities: activitiesForSelectedMonth[date]?.activities ?? [],
            notes: activitiesForSelectedMonth[date]?.notes ?? [],
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
        ),
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
