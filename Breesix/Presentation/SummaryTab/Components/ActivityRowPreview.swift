//  ActivityRowPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//

import SwiftUI

struct ActivityRowPreview: View {
    @Binding var activity: UnsavedActivity
    let student: Student
    let onAddActivity: () -> Void
    let onDelete: () -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void 
    
    @State private var showDeleteAlert = false
    @State private var selectedStatus: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(activity.activity)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .padding(.bottom, 12)
            
            HStack(spacing: 8) {
                StatusPicker(isIndependent: $activity.isIndependent) { newStatus in
                    selectedStatus = newStatus
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
                        onDeleteActivity(activity)
                        onDelete()
                    }
                    Button("Batal", role: .cancel) { }
                } message: {
                    Text("Apakah kamu yakin ingin menghapus catatan ini?")
                }
            }
        }
        .onAppear {
            selectedStatus = activity.isIndependent
        }
    }
}

#Preview {
    ActivityRowPreview(activity: .constant(.init(activity: "Menjahit", createdAt: .now, studentId: Student.ID())), student: .init(fullname: "Rangga Biner", nickname: "Rangga"), onAddActivity: { print("added activity")}, onDelete: {print("deleted")}, onDeleteActivity: { _ in print("deleted activity")})
}
