//  ManageActivityView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.

import SwiftUI
import Mixpanel

struct ManageActivityView: View {
    @State private var activityText: String
    @State private var showAlert: Bool = false
    @State private var selectedStatus: Status = .dibimbing
    
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    let onSave: (Activity) async -> Void
    let onUpdate: (Activity) -> Void
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    
    enum Mode: Equatable {
        case add
        case edit(Activity)
        
        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.add, .add):
                return true
            case let (.edit(activity1), .edit(activity2)):
                return activity1.id == activity2.id
            default:
                return false
            }
        }
    }
    
    private let titleColor = UIConstants.ManageActivity.titleColor
    private let placeholderColor = UIConstants.ManageActivity.placeholderColor
    private let textColor = UIConstants.ManageActivity.textColor
    private let textFieldBackground = UIConstants.ManageActivity.textFieldBackground
    private let borderColor = UIConstants.ManageActivity.borderColor
    private let statusMenuBackground = UIConstants.ManageActivity.statusMenuBackground
    
    private let spacing = UIConstants.ManageActivity.spacing
    private let innerSpacing = UIConstants.ManageActivity.innerSpacing
    private let statusMenuSpacing = UIConstants.ManageActivity.statusMenuSpacing
    private let topPadding = UIConstants.ManageActivity.topPadding
    private let horizontalPadding = UIConstants.ManageActivity.horizontalPadding
    private let toolbarTopPadding = UIConstants.ManageActivity.toolbarTopPadding
    private let cornerRadius = UIConstants.ManageActivity.cornerRadius
    private let borderWidth = UIConstants.ManageActivity.borderWidth
    private let textFieldPadding = UIConstants.ManageActivity.textFieldPadding
    private let statusMenuPadding = UIConstants.ManageActivity.statusMenuPadding
    
    private let addActivityTitle = UIConstants.ManageActivity.addActivityTitle
    private let editActivityTitle = UIConstants.ManageActivity.editActivityTitle
    private let placeholderText = UIConstants.ManageActivity.placeholderText
    private let backButtonText = UIConstants.ManageActivity.backButtonText
    private let saveButtonText = UIConstants.ManageActivity.saveButtonText
    private let alertTitle = UIConstants.ManageActivity.alertTitle
    private let alertMessage = UIConstants.ManageActivity.alertMessage
    private let okButtonText = UIConstants.ManageActivity.okButtonText
    private let backIcon = UIConstants.ManageActivity.backIcon
    
    let mode: Mode
    
    init(mode: Mode,
         student: Student,
         selectedDate: Date,
         onDismiss: @escaping () -> Void,
         onSave: @escaping (Activity) async -> Void,
         onUpdate: @escaping (Activity) -> Void) {
        self.mode = mode
        self.student = student
        self.selectedDate = selectedDate
        self.onDismiss = onDismiss
        self.onSave = onSave
        self.onUpdate = onUpdate
        
        switch mode {
        case .add:
            _activityText = State(initialValue: "")
        case .edit(let activity):
            _activityText = State(initialValue: activity.activity)
            _selectedStatus = State(initialValue: activity.status)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: spacing) {
                Text(mode == .add ? addActivityTitle : editActivityTitle)
                    .foregroundStyle(titleColor)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: innerSpacing) {
                    ZStack(alignment: .leading) {
                        if activityText.isEmpty {
                            Text(placeholderText)
                                .foregroundStyle(placeholderColor)
                                .font(.body)
                                .fontWeight(.regular)
                                .padding(textFieldPadding)
                        }
                        
                        TextField("", text: $activityText)
                            .foregroundStyle(textColor)
                            .font(.body)
                            .fontWeight(.regular)
                            .padding(textFieldPadding)
                    }
                    .background(textFieldBackground)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                    
                    if mode == .add {
                        StatusMenu(selectedStatus: $selectedStatus)
                    }
                }
                
                Spacer()
            }
            .padding(.top, topPadding)
            .padding(.horizontal, horizontalPadding)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(mode == .add ? addActivityTitle : editActivityTitle)
                        .foregroundStyle(titleColor)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, toolbarTopPadding)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onDismiss() }) {
                        HStack(spacing: 3) {
                            Image(systemName: backIcon)
                                .fontWeight(.semibold)
                            Text(backButtonText)
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.top, toolbarTopPadding)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if activityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showAlert = true
                        } else {
                            saveActivity()
                        }
                    }) {
                        Text(saveButtonText)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.top, toolbarTopPadding)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button(okButtonText, role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveActivity() {
        switch mode {
        case .add:
            let newActivity = Activity(
                activity: activityText,
                createdAt: selectedDate,
                status: selectedStatus,
                student: student
            )
            
            trackActivityCreation(newActivity)
            
            Task {
                await onSave(newActivity)
                onDismiss()
            }
            
        case .edit(let activity):
            var updatedActivity = activity
            updatedActivity.activity = activityText
            onUpdate(updatedActivity)
            onDismiss()
        }
    }
    
    private func trackActivityCreation(_ activity: Activity) {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_text_length": activityText.count,
            "status": selectedStatus.rawValue,
            "created_at": selectedDate.timeIntervalSince1970,
            "screen": "add_activity",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Created", properties: properties)
    }
}

#Preview {
    ManageActivityView(
        mode: .add,
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        selectedDate: .now,
        onDismiss: { print("dismissed") },
        onSave: { _ in print("saved") },
        onUpdate: { _ in print("updated") }
    )
}
