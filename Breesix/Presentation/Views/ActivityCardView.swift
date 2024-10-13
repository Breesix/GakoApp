//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct ActivityCardView: View {
    let activities: [Activity]
    let notes: [Note]
    let onAddNote: () -> Void
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ActivitySection(
                activities: activities,
                onEditActivity: onEditActivity,
                onDeleteActivity: onDeleteActivity
            )
            
            NoteSection(
                notes: notes,
                onEditNote: onEditNote,
                onDeleteNote: onDeleteNote,
                onAddNote: onAddNote
            )
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color(red: 0.92, green: 0.96, blue: 0.96))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.25)
                .stroke(.green, lineWidth: 0.5)
        )
    }
}

struct ActivitySection: View {
    let activities: [Activity]
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Aktivitas")
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
            
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach(activities, id: \.id) { activity in
                    ActivityRow(activity: activity, onEdit: onEditActivity, onDelete: onDeleteActivity)
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

struct ActivityRow: View {
    let activity: Activity
    let onEdit: (Activity) -> Void
    let onDelete: (Activity) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let status = activity.isIndependent {
                HStack {
                    Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(status ? "Mandiri" : "Dibimbing")
                }
                .foregroundColor(status ? .green : .red)
            }
            VStack {
                Text(activity.activity)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(8)
        }
        .contextMenu {
            Button("Edit") { onEdit(activity) }
            Button("Hapus", role: .destructive) { onDelete(activity) }
        }
    }
}

struct NoteDetailRow: View {
    let note: Note
    let onEdit: (Note) -> Void
    let onDelete: (Note) -> Void
    
    var body: some View {
        Text(note.note)
            .font(.caption)
            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(8)
            .contextMenu {
                Button("Edit") { onEdit(note) }
                Button("Hapus", role: .destructive) { onDelete(note) }
            }
    }
}
