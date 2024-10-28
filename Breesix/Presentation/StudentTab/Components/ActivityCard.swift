//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct ActivityCardView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    let activities: [Activity]  // Changed from @State to let
    let notes: [Note]
    let date: Date
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let student: Student
    
    func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(indonesianFormattedDate(date: date))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
            }
            .padding(.bottom, 19)
        
            ActivitySection(
                activities: activities,
                onEditActivity: onEditActivity,
                onDeleteActivity: onDeleteActivity,
                onAddActivity: onAddActivity,
                onStatusChanged: { activity, newStatus in
                    Task {
                        await viewModel.updateActivityStatus(activity, isIndependent: newStatus)
                    }
                }
            )
            .padding(.bottom, 16)
            
            Divider()
                .frame(height: 1)
                .background(.tabbarInactiveLabel)
                .padding(.bottom, 20)
            
            NoteSection(
                notes: notes,
                onEditNote: onEditNote,
                onDeleteNote: onDeleteNote,
                onAddNote: onAddNote
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}


struct ActivitySection: View {
    let activities: [Activity]  // Changed from @Binding to let
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onAddActivity: () -> Void
    let onStatusChanged: (Activity, Bool) -> Void  // Tambahkan ini
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach(activities, id: \.id) { activity in
                    ActivityRow(
                        activity: activity,
                        onEdit: onEditActivity,
                        onDelete: onDeleteActivity,
                        onStatusChanged: onStatusChanged  // Teruskan handler
                    )
                }
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
        }
    }
}

struct ActivityRow: View {
    let activity: Activity  // Changed from @Binding to let
    let onEdit: (Activity) -> Void
    let onDelete: (Activity) -> Void
    let onStatusChanged: (Activity, Bool) -> Void  // Tambahkan handler untuk perubahan status

    @State private var showDeleteAlert = false
    @State private var isIndependent: Bool  // Add this to handle the picker state

    init(activity: Activity,
         onEdit: @escaping (Activity) -> Void,
         onDelete: @escaping (Activity) -> Void,
         onStatusChanged: @escaping (Activity, Bool) -> Void) {
        self.activity = activity
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onStatusChanged = onStatusChanged
        _isIndependent = State(initialValue: activity.isIndependent ?? false)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(activity.activity)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
            
            if activity.isIndependent != nil {
                HStack(spacing: 0) {
                    Picker("Status", selection: $isIndependent) {
                        Text("Mandiri").tag(true)
                        Text("Dibimbing").tag(false)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(.trailing, 8)
                    .onChange(of: isIndependent) { newValue in
                        onStatusChanged(activity, newValue)  // Panggil handler saat status berubah
                    }

                    
                    Button("Hapus", systemImage: "trash.fill", action: {
                        showDeleteAlert = true
                    })
                    .frame(width: 34, height: 34)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .clipShape(.circle)
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
}



    

struct NoteDetailRow: View {
    let note: Note
    let onEdit: (Note) -> Void
    let onDelete: (Note) -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack {
            Text(note.note)
                .font(.subheadline)
                .foregroundColor(.labelPrimaryBlack)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .contextMenu {
                    Button("Edit") { onEdit(note) }
                }
            
            Spacer()
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Image("custom.trash.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34)
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

