//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI





struct ActivityCardView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    let activities: [Activity]
    let notes: [Note]
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let student: Student
    let date: Date
    
    func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(indonesianFormattedDate(date: date))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
            }
            .padding(.bottom, 19)
            if !activities.isEmpty {
                
                    ActivitySection(
                        activities: activities,
                        onEditActivity: onEditActivity,
                        onDeleteActivity: onDeleteActivity,
                        onStatusChanged: { activity, newStatus in
                            Task {
                                await viewModel.updateActivityStatus(activity, isIndependent: newStatus)
                            }
                        }
                    )
//                    .padding(.bottom, 16)
                
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.secondary)
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
                    .foregroundColor(.secondary)
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


struct ActivitySection: View {
    let activities: [Activity]
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onStatusChanged: (Activity, Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach(activities, id: \.id) { activity in
                    ActivityRow(
                        activity: activity,
                        onEdit: { _ in onEditActivity(activity) },
                        onDelete: { _ in onDeleteActivity(activity) },
                        onStatusChanged: { newStatus  in
                            onStatusChanged(activity, newStatus)
                        }
                        )
                }
            }
            
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    let onEdit: (Activity) -> Void
    let onDelete: (Activity) -> Void
    let onStatusChanged: (Bool) -> Void
    @State private var showDeleteAlert = false
    @State private var isIndependent: Bool
    
    init(activity: Activity,
         onEdit: @escaping (Activity) -> Void,
         onDelete: @escaping (Activity) -> Void,
         onStatusChanged: @escaping (Bool) -> Void) {
        self.activity = activity
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onStatusChanged = onStatusChanged
        _isIndependent = State(initialValue: activity.isIndependent ?? false)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(activity.activity)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .padding(.bottom, 12)
            
            if activity.isIndependent != nil {
                HStack(spacing: 8) {
                    Menu {
                        Button("Mandiri") {
                            isIndependent = true
                            onStatusChanged(true)
                        }
                        Button("Dibimbing") {
                            isIndependent = false
                            onStatusChanged(false)
                        }
                    } label: {
                        HStack {
                            Text(getStatusText())
                            
                            Spacer()
                            
                            Image(systemName: "chevron.up.chevron.down")
                        }
                        .font(.body)
                        .fontWeight(.regular)
                        .foregroundColor(.labelPrimaryBlack)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 11)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.cardFieldBG)
                        .cornerRadius(8)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.statusStroke, lineWidth: 2)
                        }
                    }
                    
                    
                    Button(action: { showDeleteAlert = true }) {
                        Image("custom.trash.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34)
                    }
                    .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                        Button("Hapus", role: .destructive) {
                            onDelete(activity)
                        }
                        Button("Batal", role: .cancel) { }
                    } message: {
                        Text("Apakah kamu yakin ingin menghapus aktivitas ini?")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func getStatusText() -> String {
        return isIndependent ? "Mandiri" : "Dibimbing"
    }
}





struct NoteDetailRow: View {
    let note: Note
    let onEdit: (Note) -> Void
    let onDelete: (Note) -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack (spacing: 8) {
            Text(note.note)
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundStyle(.labelPrimaryBlack)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(8)
                .background(.monochrome100)
                .cornerRadius(8)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.noteStroke, lineWidth: 0.5)
                }
                .contextMenu {
                    Button("Edit") { onEdit(note) }
                }
            
            
            Button(action: {
                showDeleteAlert = true
            }) {
                ZStack {
                    Circle()
                        .frame(width: 34)
                        .foregroundStyle(.buttonDestructiveOnCard)
                    Image(systemName: "trash.fill")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.destructive)
                }
            }
            .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                Button("Hapus", role: .destructive) {
                    onDelete(note)
                }
                Button("Batal", role: .cancel) { }
            } message: {
                Text("Apakah kamu yakin ingin menghapus catatan ini?")
            }
        }
    }
}

