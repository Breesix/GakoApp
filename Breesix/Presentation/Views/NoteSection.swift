//
//  NoteSection.swift
//  Breesix
//
//  Created by Akmal Hakim on 10/10/24.
//

import SwiftUI

struct NoteSection: View {
    let notes: [Note]
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let onAddNote: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Catatan")
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
            
            if notes.isEmpty {
                Text("Tidak ada catatan untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach(notes, id: \.id) { note in
                    NoteDetailRow(note: note, onEdit: onEditNote, onDelete: onDeleteNote)
                }
            }
            
            Button(action: onAddNote) {
                Label("Tambah", systemImage: "plus.app.fill")
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal, 12)
    }
}
