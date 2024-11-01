//
//  DailyReportCard.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct DailyReportCard: View {
    @ObservedObject var viewModel: StudentTabViewModel
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
                
                Button(action: { onShareTapped(date) }) {
                    ZStack {
                        Circle()
                            .frame(width: 34)
                            .foregroundStyle(.buttonOncard)
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundStyle(.buttonPrimaryLabel)
                    }
                }
            }
            .padding(.bottom, 19)
            
            if !activities.isEmpty {
                ActivitySection(
                    activities: activities,
                    onDeleteActivity: onDeleteActivity,
                    onStatusChanged: { activity, newStatus in
                        Task {
                            await viewModel.updateActivityStatus(activity, isIndependent: newStatus)
                        }
                    }
                )
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
            }
            
            Button(action: onAddActivity) {
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
                .padding(.bottom, 20)
            
            if !notes.isEmpty {
                NoteSection(
                    notes: notes,
                    onEditNote: onEditNote,
                    onDeleteNote: onDeleteNote,
                    onAddNote: onAddNote
                )
            } else {
                Text("Tidak ada notes untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
            }
            
            Button(action: onAddNote) {
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
}

// Custom Share Button Component
struct ShareButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(10)
        }
    }
}
