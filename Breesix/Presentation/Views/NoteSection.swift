//
//  NoteSection.swift
//  Breesix
//
//  Created by Akmal Hakim on 10/10/24.
//

import SwiftUI

struct NoteSection: View {
    let activities: [Note]
    let onEditActivity: (Note) -> Void
    let onDeleteActivity: (Note) -> Void
    let onAddActivity: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Aktivitas Umum")
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
            
            if activities.isEmpty {
                Text("Tidak ada catatan untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach(activities, id: \.id) { activity in
                    ActivityDetailRow(activity: activity, onEdit: onEditActivity, onDelete: onDeleteActivity)
                }
            }
            
            Button(action: onAddActivity) {
                Label("Tambah", systemImage: "plus.app.fill")
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 12)
    }
}
