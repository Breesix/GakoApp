//  ActivityRowPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//

import SwiftUI

struct ActivityRowPreview: View {
    @Binding var activity: UnsavedActivity
    let activityIndex: Int
    let student: Student
    let onAddActivity: () -> Void
    let onEdit: (UnsavedActivity) -> Void
    let onDelete: () -> Void
    let onDeleteActivity: (UnsavedActivity) -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Aktivitas \(activityIndex + 1)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)

                Spacer()

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
                }
            
            Text(activity.activity)
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
                    onEdit(activity)
                }

            HStack(spacing: 8) {
                StatusPicker(status: $activity.status) { newStatus in
                    activity.status = newStatus
                }
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

#Preview {
    ActivityRowPreview(
        activity: .constant(.init(
            activity: "Menjahit",
            createdAt: .now,
            studentId: Student.ID()
        )),
        activityIndex: 0,
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        onAddActivity: { print("added activity") },
        onEdit: { _ in print("edit activity") },
        onDelete: { print("deleted") },
        onDeleteActivity: { _ in print("deleted activity") }
    )
}
