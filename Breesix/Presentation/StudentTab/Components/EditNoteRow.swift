//
//  EditNoteRow.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI

struct EditNoteRow: View {
    @State private var showDeleteAlert = false
    @State private var showingEditSheet = false  // Tambahkan state ini
    let note: Note
    let onEdit: (Note) -> Void
    let onDelete: (Note) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
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
                        showingEditSheet = true
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
            }
        }
        .alert("Hapus Catatan", isPresented: $showDeleteAlert) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive) {
                onDelete(note)
            }
        } message: {
            Text("Apakah Anda yakin ingin menghapus catatan ini?")
        }
    }
}

#Preview {
    EditNoteRow(note: .init(note: "rangga sangat hebat sekali dalam mengerjakan tugasnya dia keren banget jksdahbhfjkbsadfjkbhjfabjshfbshjadbfhjbfashjbhjbadshjfbjhabfhjsaf", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onEdit: { _ in print("clicked")}, onDelete: { _ in print("deleted")})
}
