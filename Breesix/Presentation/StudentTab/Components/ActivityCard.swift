//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI


//struct ActivityCardView: View {
//    @ObservedObject var viewModel: StudentTabViewModel
//    let activities: [Activity]
//    let notes: [Note]
//    let onAddNote: () -> Void
//    let onAddActivity: () -> Void
//    let onEditActivity: (Activity) -> Void
//    let onDeleteActivity: (Activity) -> Void
//    let onEditNote: (Note) -> Void
//    let onDeleteNote: (Note) -> Void
//    let student: Student
//    let date: Date
//    
//    @State private var showSnapshotPreview = false
//    @State private var snapshotImage: UIImage?
//    @State private var selectedActivityDate: Date?
//    
//    let onShareTapped: (Date) -> Void
//    
//    func indonesianFormattedDate(date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "id_ID")
//        formatter.dateStyle = .full
//        formatter.timeStyle = .none
//        return formatter.string(from: date)
//    }
//    
//    func shareReport() {
//        let reportView = DailyReportTemplate(
//            student: student,
//            activities: activities,
//            notes: notes,
//            date: date
//        )
//        
//        let image = reportView.snapshot()
//        
//        let activityVC = UIActivityViewController(
//            activityItems: [image],
//            applicationActivities: nil
//        )
//        
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = windowScene.windows.first,
//           let rootVC = window.rootViewController {
//            rootVC.present(activityVC, animated: true)
//        }
//    }
//        
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                Text(indonesianFormattedDate(date: date))
//                    .font(.body)
//                    .fontWeight(.semibold)
//                    .foregroundStyle(.labelPrimaryBlack)
//                
//                Spacer()
//                
//                Button(action: { onShareTapped(date) }) {
//                    ZStack {
//                        Circle()
//                            .frame(width: 34)
//                            .foregroundStyle(.buttonOncard)
//                        Image(systemName: "square.and.arrow.up.fill")
//                            .font(.subheadline)
//                            .fontWeight(.regular)
//                            .foregroundStyle(.buttonPrimaryLabel)
//                    }
//                }
//            }
//            .padding(.bottom, 19)
//            if !activities.isEmpty {
//                
//                    ActivitySection(
//                        activities: activities,
////                        onEditActivity: onEditActivity,
//                        onDeleteActivity: onDeleteActivity,
//                        onStatusChanged: { activity, newStatus in
//                            Task {
//                                await viewModel.updateActivityStatus(activity, isIndependent: newStatus)
//                            }
//                        }
//                    )
////                    .padding(.bottom, 16)
//                
//            } else {
//                Text("Tidak ada aktivitas untuk tanggal ini")
//                    .foregroundColor(.labelSecondary)
//            }
//            
//            Button(action: onAddActivity) {
//                Label("Tambah", systemImage: "plus.app.fill")
//            }
//            .padding(.vertical, 7)
//            .padding(.horizontal, 14)
//            .font(.footnote)
//            .fontWeight(.regular)
//            .foregroundStyle(.buttonPrimaryLabel)
//            .background(.buttonOncard)
//            .cornerRadius(8)
//            
//            Divider()
//                .frame(height: 1)
//                .background(.tabbarInactiveLabel)
//                .padding(.bottom, 20)
//            
//            
//            if !notes.isEmpty {
//                NoteSection(
//                    notes: notes,
//                    onEditNote: onEditNote,
//                    onDeleteNote: onDeleteNote,
//                    onAddNote: onAddNote
//                )
//            } else {
//                Text("Tidak ada notes untuk tanggal ini")
//                    .foregroundColor(.labelSecondary)
//            }
//            Button(action: onAddNote) {
//                Label("Tambah", systemImage: "plus.app.fill")
//            }
//            .padding(.vertical, 7)
//            .padding(.horizontal, 14)
//            .font(.footnote)
//            .fontWeight(.regular)
//            .foregroundStyle(.buttonPrimaryLabel)
//            .background(.buttonOncard)
//            .cornerRadius(8)
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(.white)
//        .cornerRadius(20)
//        .frame(maxWidth: .infinity, alignment: .trailing)        
//    }
//}
//
//struct NoteDetailRow: View {
//    let note: Note
//    let onEdit: (Note) -> Void
//    let onDelete: (Note) -> Void
//    
//    @State private var showDeleteAlert = false
//    
//    var body: some View {
//        HStack (spacing: 8) {
//            Text(note.note)
//                .font(.subheadline)
//                .fontWeight(.regular)
//                .foregroundStyle(.labelPrimaryBlack)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(8)
//                .background(.monochrome100)
//                .cornerRadius(8)
//                .overlay {
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(.noteStroke, lineWidth: 0.5)
//                }
//                .contextMenu {
//                    Button("Edit") { onEdit(note) }
//                }
//            
//            
//            Button(action: {
//                showDeleteAlert = true
//            }) {
//                ZStack {
//                    Circle()
//                        .frame(width: 34)
//                        .foregroundStyle(.buttonDestructiveOnCard)
//                    Image(systemName: "trash.fill")
//                        .font(.subheadline)
//                        .fontWeight(.regular)
//                        .foregroundStyle(.destructive)
//                }
//            }
//            .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
//                Button("Hapus", role: .destructive) {
//                    onDelete(note)
//                }
//                Button("Batal", role: .cancel) { }
//            } message: {
//                Text("Apakah kamu yakin ingin menghapus catatan ini?")
//            }
//        }
//    }
//}

