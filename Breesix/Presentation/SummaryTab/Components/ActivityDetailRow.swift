//
//  ActivityDetailRow.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//
import SwiftUI

struct ActivityDetailRow: View {
    @Binding var activity: UnsavedActivity
    let student: Student
    let onAddActivity: () -> Void
    let onDelete: () -> Void

    @State private var selectedStatus: Bool?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(activity.activity)
                .font(.headline)
            
            HStack {
                Menu {
                    Button("Mandiri") {
                        activity.isIndependent = true
                        selectedStatus = true // Update state
                    }
                    Button("Dibimbing") {
                        activity.isIndependent = false
                        selectedStatus = false // Update state
                    }
                } label: {
                    HStack {
                        Text(getStatusText())
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.up.chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image("custom.trash.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24) // Perbesar ukuran icon
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            // Initialize selectedStatus when view appears
            selectedStatus = activity.isIndependent
        }
    }
    
    // Helper function untuk mendapatkan text status
    private func getStatusText() -> String {
        if let isIndependent = activity.isIndependent {
            return isIndependent ? "Mandiri" : "Dibimbing"
        }
        return "Status"
    }
}


