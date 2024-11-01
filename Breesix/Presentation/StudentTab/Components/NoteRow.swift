//
//  NoteRow.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct NoteRow: View {
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

#Preview {
    NoteRow(note: .init(note: "rangga sangat hebat sekali dalam mengerjakan tugasnya dia keren banget", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onEdit: { _ in print("edited")}, onDelete: { _ in print("deleted")})
}
