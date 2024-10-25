//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct ActivityCard: View {
    let activities: [Activity]
    let notes: [Note]
    let date: Date  // Add date parameter
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    
    func indonesianFormattedDate(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "id_ID")
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                Text(indonesianFormattedDate(date: date))
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .padding(.bottom, 8)
                
                Spacer()
                
                Button("Share", systemImage: "square.and.arrow.up.fill", action: onAddActivity)
                    .frame(width: 34, height: 34)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .foregroundStyle(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .background(Color.buttonOncard)
                    .cornerRadius(999)
            }
            
            // Activities section
            ActivitySection(
                activities: activities,
                onEditActivity: onEditActivity,
                onDeleteActivity: onDeleteActivity,
                onAddActivity: onAddActivity
            )
            
            // Divider
            Divider()
                .padding(.vertical, 8)
            
            // Notes section
            NoteSection(
                notes: notes,
                onEditNote: onEditNote,
                onDeleteNote: onDeleteNote,
                onAddNote: onAddNote
            )
        }
        .padding(16)
        .background(.white)
        .cornerRadius(20)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .inset(by: 0.25)
//                .stroke(.green, lineWidth: 0.5)
//        )
    }
}
struct ActivitySection: View {
    let activities: [Activity]
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onAddActivity: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach(activities, id: \.id) { activity in
                    ActivityRow(activity: activity, onEdit: onEditActivity, onDelete: onDeleteActivity)
                }
            }
            Button(action: onAddActivity) {
                Label("Tambah", systemImage: "plus.app.fill")
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color(red: 0.24, green: 0.24, blue: 0.24))
            .background(Color.buttonOncard)
        }
//        .padding(12)
//        .background(.white)
//        .cornerRadius(8)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .inset(by: 0.25)
//                .stroke(.green, lineWidth: 0.5)
//        )
    }
}

struct ActivityRow: View {
    let activity: Activity
    let onEdit: (Activity) -> Void
    let onDelete: (Activity) -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack {
                Text(activity.activity)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            if let status = activity.isIndependent {
                HStack {
                    VStack {
                        Text(status ? "Mandiri" : "Dibimbing")
                    }
                    .foregroundColor(status ? .green : .red)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("Hapus", systemImage: "trash.fill", action: {
                        showDeleteAlert = true // Show alert when button is pressed
                    })
                    .frame(width: 34, height: 34)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .cornerRadius(999)
                    .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                        Button("Hapus", role: .destructive) {
                            onDelete(activity) // Delete confirmed
                        }
                        Button("Batal", role: .cancel) { }
                    } message: {
                        Text("Apakah kamu yakin ingin menghapus aktivitas ini?")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contextMenu {
            Button("Edit") { onEdit(activity) }
            Button("Hapus", role: .destructive) {
                showDeleteAlert = true // Show alert for context menu delete
            }
        }
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
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .contextMenu {
                    Button("Edit") { onEdit(note) }
                    Button("Hapus", role: .destructive) {
                        showDeleteAlert = true // Show alert for context menu delete
                    }
                }
            
            Spacer()
            
            Button("Hapus", systemImage: "trash.fill", action: {
                showDeleteAlert = true // Show alert when button is pressed
            })
            .labelStyle(.iconOnly)
            .buttonStyle(.bordered)
            .tint(.red)
            .cornerRadius(999)
            .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                Button("Hapus", role: .destructive) {
                    onDelete(note) // Delete confirmed
                }
                Button("Batal", role: .cancel) { }
            } message: {
                Text("Apakah kamu yakin ingin menghapus catatan ini?")
            }
        }
    }
}

