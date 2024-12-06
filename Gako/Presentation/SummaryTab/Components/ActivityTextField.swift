//
//  ActivityTextField.swift
//  Gako
//
//  Created by Kevin Fairuz on 13/11/24.
//
//  Description: A text field for editing an activity.
//  Usage: Use this view to add a new activity or edit an existing activity.    

import SwiftUI

struct ActivityTextField: View {
    @EnvironmentObject private var activityViewModel: ActivityViewModel
    let activity: UnsavedActivity
    @State private var text: String
    
    init(activity: UnsavedActivity) {
        self.activity = activity
        _text = State(initialValue: activity.activity)
    }
    
    var body: some View {
        HStack {
            TextField("", text: $text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green, lineWidth: 1)
                )
                .onChange(of: text) { newValue in
                    let updatedActivity = UnsavedActivity(
                        id: activity.id,
                        activity: newValue,
                        createdAt: activity.createdAt,
                        status: activity.status,
                        studentId: activity.studentId
                    )
                    activityViewModel.updateUnsavedActivity(updatedActivity)
                }
            
            Button(action: {
                activityViewModel.deleteUnsavedActivity(activity)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
