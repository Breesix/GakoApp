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
    
    init(activity: Activity,
         onDelete: @escaping (Activity) -> Void,
         onStatusChanged: @escaping (Activity, Bool?) -> Void) {
        self.activity = activity
        self.onDelete = onDelete
        self.onStatusChanged = onStatusChanged
        _isIndependent = State(initialValue: activity.isIndependent)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(activity.activity)
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
                .padding(.bottom, 12)
            
            HStack(spacing: 8) {
                Menu {
                    Button("Mandiri") {
                        isIndependent = true
                        onStatusChanged(activity, true)
                    }
                    Button("Dibimbing") {
                        isIndependent = false
                        onStatusChanged(activity, false)
                    }
                    Button("Tidak Melakukan") {
                        isIndependent = nil
                        onStatusChanged(activity, nil)
                    }
                } label: {
                    HStack {
                        Text(getStatusText())
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .font(.body)
                    .fontWeight(.regular)
                    .foregroundColor(.labelPrimaryBlack)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.cardFieldBG)
                    .cornerRadius(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.statusStroke, lineWidth: 2)
                    }
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
    
    private func getStatusText() -> String {
        switch isIndependent {
        case true:
            return "Mandiri"
        case false:
            return "Dibimbing"
        case nil:
            return "Tidak Melakukan"
        default:
            return "status"
        }
    }
}

#Preview {
    ActivityRow(activity: .init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga")), onDelete: {_ in print("deleted")}, onStatusChanged: { _, _ in print("changed")})
}
