//
//  ActivityTextField.swift
//  Breesix
//
//  Created by Kevin Fairuz on 13/11/24.
//
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

//private struct ActivityViewModelKey: EnvironmentKey {
//    static let defaultValue: ActivityViewModel = ActivityViewModel(studentViewModel: StudentViewModel( studentUseCases: StudentUseCase), activityUseCases: ActivityUseCaseImpl(repository: any ActivityRepository))
//}
//
//extension EnvironmentValues {
//    var activityViewModel: ActivityViewModel {
//        get { self[ActivityViewModelKey.self] }
//        set { self[ActivityViewModelKey.self] = newValue }
//    }
//}
