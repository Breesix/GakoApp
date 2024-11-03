//
//  ActivityRow.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct ActivityRow: View {
    let activity: Activity
    let onDelete: (Activity) -> Void
    let onStatusChanged: (Activity, Bool?) -> Void
    @State private var showDeleteAlert = false
    @State private var isIndependent: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(activity.activity)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .padding(.bottom, 12)
            
            HStack(spacing: 8) {
                StatusPicker(isIndependent: $isIndependent) { newStatus in
                    onStatusChanged(activity, newStatus)
                }
                
                Button(action: { showDeleteAlert = true }) {
                    Image("custom.trash.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34)
                }
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            isIndependent = activity.isIndependent
        }
    }
}

#Preview {
    ActivityRow(
        activity: .init(
            activity: "Menjahit",
            student: .init(fullname: "Rangga Biner", nickname: "Rangga")
        ),
        onDelete: {_ in print("deleted")},
        onStatusChanged: { _, _ in print("changed")}
    )
}
