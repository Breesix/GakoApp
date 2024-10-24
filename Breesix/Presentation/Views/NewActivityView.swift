//
//  NewActivityView.swift
//  Breesix
//
//  Created by Rangga Biner on 13/10/24.
//

import SwiftUI

struct NewActivityView: View {
    @ObservedObject var viewModel: StudentListViewModel
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    
    @State private var activityText: String = ""
    @State private var status: Bool = false

    var body: some View {
        NavigationView {
            Form {
                
                TextField("Aktivitas", text: $activityText)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                
                // Toggle for status (Mandiri or not)
                Toggle("Mandiri", isOn: $status)
                    .padding()

                // Save button to save the activity
                Button("Simpan Perubahan") {
                    saveNewActivity()
                }
                .padding()
            }
            .navigationTitle("Aktivitas Baru")
            .navigationBarItems(trailing: Button("Tutup") {
                onDismiss()
            })
        }
    }

    // Function to save the new activity
    private func saveNewActivity() {
        
        let newActivity = UnsavedActivity(activity: activityText, createdAt: selectedDate, isIndependent: status, studentId: student.id)
        Task {
            viewModel.addUnsavedActivities([newActivity])  // Add the new activity to the viewModel
            onDismiss()  
        }
    }
}




