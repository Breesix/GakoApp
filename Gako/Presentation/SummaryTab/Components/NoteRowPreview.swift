//
//  NoteRow.swift
//  Breesix
//
//  Created by Kevin Fairuz on 28/10/24.
//
import SwiftUI

struct NoteRowPreview: View {
    let note: UnsavedNote
    
    let onEdit: (UnsavedNote) -> Void
    let onDelete: (UnsavedNote) -> Void
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 8) {
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
                .onTapGesture {
                    onEdit(note)
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
                        .foregroundStyle(.destructiveOnCardLabel)
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
