//
//  StudentStudentDailyReportCard.swift
//  Breesix
//
//  Created by Rangga Biner on 08/11/24.
//

import SwiftUI

struct StudentDailyReportCard: View {
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
    
    var body: some View {
         VStack(alignment: .leading, spacing: 12) {
                 ActivitySection(
                     activities: activities,
                     onStatusChanged: { activity, newStatus in
                         Task {
                             await onUpdateActivityStatus(activity, newStatus)
                         }
                     }
                 )
                 .disabled(true)
                 .padding(.horizontal, 16)
             
             Divider()
                 .frame(height: 1)
                 .background(.tabbarInactiveLabel)
                 .padding(.bottom, 4)
                 .padding(.top, 4)
             
                 NoteSection(
                     notes: notes,
                     onEditNote: onEditNote,
                     onDeleteNote: onDeleteNote,
                     onAddNote: onAddNote
                 )
                 .padding(.horizontal, 16)
             
//             // Tombol Tambah Catatan
//             Button(action: onAddNote) {
//                 Label("Tambah", systemImage: "plus.app.fill")
//             }
//             .padding(.vertical, 7)
//             .padding(.horizontal, 14)
//             .font(.footnote)
//             .fontWeight(.regular)
//             .foregroundStyle(.buttonPrimaryLabel)
//             .background(.buttonOncard)
//             .cornerRadius(8)
//             .padding(.horizontal, 16)
         }
         .padding(.vertical, 16)
         .background(.white)
         .cornerRadius(20)
         .frame(maxWidth: .infinity, alignment: .trailing)
     }
}

#Preview {
    StudentDailyReportCard(
        activities: [
            .init(activity: "Senam", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(activity: "Makan ikan", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
        ],
        notes: [
            .init(note: "Anak sangat aktif hari ini", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(note: "Keren banget dah wadidaw", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
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
