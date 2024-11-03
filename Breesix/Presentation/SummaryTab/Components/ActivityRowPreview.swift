//
//  ActivityRowPreview.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct ActivityRowPreview: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @Binding var activity: UnsavedActivity
    let student: Student
    let onAddActivity: () -> Void
    let onDelete: () -> Void
    
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
                        viewModel.deleteUnsavedActivity(activity)
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




