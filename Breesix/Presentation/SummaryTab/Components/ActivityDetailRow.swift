//
//  ActivityDetailRow.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct ActivityDetailRow: View {
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
            
            HStack (spacing: 8) {
                Menu {
                    Button("Mandiri") {
                        activity.isIndependent = true
                        selectedStatus = true
                    }
                    Button("Dibimbing") {
                        activity.isIndependent = false
                        selectedStatus = false 
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
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image("custom.trash.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34)
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
    
    private func getStatusText() -> String {
        if let isIndependent = activity.isIndependent {
            return isIndependent ? "Mandiri" : "Dibimbing"
        }
        return "Status"
    }
}


