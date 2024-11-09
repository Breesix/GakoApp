//
//  DailyReportCard.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct DailyReportCard: View {
    let activities: [Activity]
    let notes: [Note]
    let student: Student
    let date: Date
    
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let onShareTapped: (Date) -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    
    @State private var showSnapshotPreview = false
    @State private var snapshotImage: UIImage?
    @State private var selectedActivityDate: Date?
    
    func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    func shareReport() {
        let reportView = DailyReportTemplate(
            student: student,
            activities: activities,
            notes: notes,
            date: date
        )
        
        let image = reportView.snapshot()
        
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(indonesianFormattedDate(date: date))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
                
                Spacer()
            
                Button(action: {
                    onShareTapped(date)
                }) {
                    ZStack {
                        Circle()
                            .frame(width: 36)
                            .foregroundStyle(.buttonOncard)
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.buttonPrimaryLabel)
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Divider()
                .frame(height: 1)
                .background(.tabbarInactiveLabel)
                .padding(.bottom, 8)

            if !activities.isEmpty {
                ActivitySection(
                    activities: activities,
                    onDeleteActivity: onDeleteActivity,
                    onStatusChanged: { activity, newStatus in
                        Task {
                            await onUpdateActivityStatus(activity, newStatus)
                        }
                    }
                )
                .disabled(true)
                .padding(.horizontal, 16)
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
                    .padding(.horizontal, 16)
            }
            
            Divider()
                .frame(height: 1)
                .background(.tabbarInactiveLabel)
                .padding(.bottom, 4)

            
            if !notes.isEmpty {
                NoteSection(
                    notes: notes,
                    onEditNote: onEditNote,
                    onDeleteNote: onDeleteNote,
                    onAddNote: onAddNote
                )
                .padding(.horizontal, 16)

            } else {
                Text("Tidak ada catatan untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
                    .padding(.horizontal, 16)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 16)
        .background(.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    DailyReportCard(
        activities: [
            .init(activity: "Senam", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(activity: "Makan ikan", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
        ],
        notes: [
            .init(note: "Anak sangat aktif hari ini", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(note: "Keren banget dah wadidaw dbashjfbhjabfhjabjfhbhjasbfhjsabfhkasdmlfmakldmsaklfmskljsadnjkfnsaf", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
        ],
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        date: .now,
        onAddNote: { print("added note") },
        onAddActivity: { print("added activity")},
        onDeleteActivity: { _ in print("deleted activity")},
        onEditNote: { _ in print("edited note")},
        onDeleteNote: { _ in print("deleted note") },
        onShareTapped: { _ in print("shared")},
        onUpdateActivityStatus: { _, _ in print("updated activity")}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
