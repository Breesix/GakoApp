//  AddUnsavedActivity.swift
//  GAKO
//
//  Created by Rangga Biner on 13/10/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: Sheets view to add or edit activity
//

import SwiftUI
import Mixpanel

struct ManageUnsavedActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var activityText: String
    @State private var showAlert: Bool = false
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    @State private var selectedStatus: Status = .dibimbing
    @State private var isBulkEdit: Bool = false
    let allActivities: [UnsavedActivity]
    let allStudents: [Student]

    enum Mode: Equatable {
        case add(Student, Date)
        case edit(UnsavedActivity)
        
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
    
    let mode: Mode
    let onSave: (UnsavedActivity) -> Void
    
    // Declare constants as variables
    private let topPadding = UIConstants.ManageUnsavedActivityViewConstants.topPadding
    private let horizontalPadding = UIConstants.ManageUnsavedActivityViewConstants.horizontalPadding
    private let verticalPadding = UIConstants.ManageUnsavedActivityViewConstants.verticalPadding
    private let cornerRadius = UIConstants.ManageUnsavedActivityViewConstants.cornerRadius
    private let strokeWidth = UIConstants.ManageUnsavedActivityViewConstants.strokeWidth
    private let buttonTopPadding = UIConstants.ManageUnsavedActivityViewConstants.buttonTopPadding
    private let toggleTopPadding = UIConstants.ManageUnsavedActivityViewConstants.toggleTopPadding
    private let menuHorizontalPadding = UIConstants.ManageUnsavedActivityViewConstants.menuHorizontalPadding
    private let menuVerticalPadding = UIConstants.ManageUnsavedActivityViewConstants.menuVerticalPadding
    private let labelPrimaryBlack = UIConstants.ManageUnsavedActivityViewConstants.labelPrimaryBlack
    private let labelTertiary = UIConstants.ManageUnsavedActivityViewConstants.labelTertiary
    private let cardFieldBG = UIConstants.ManageUnsavedActivityViewConstants.cardFieldBG
    private let monochrome50 = UIConstants.ManageUnsavedActivityViewConstants.monochrome50
    private let statusSheet = UIConstants.ManageUnsavedActivityViewConstants.statusSheet

    // Text Constants
    private let addActivityTitle = UIConstants.ManageUnsavedActivityViewConstants.addActivityTitle
    private let editActivityTitle = UIConstants.ManageUnsavedActivityViewConstants.editActivityTitle
    private let placeholderText = UIConstants.ManageUnsavedActivityViewConstants.placeholderText
    private let bulkEditToggleText = UIConstants.ManageUnsavedActivityViewConstants.bulkEditToggleText
    private let mandiriText = UIConstants.ManageUnsavedActivityViewConstants.mandiriText
    private let dibimbingText = UIConstants.ManageUnsavedActivityViewConstants.dibimbingText
    private let tidakMelakukanText = UIConstants.ManageUnsavedActivityViewConstants.tidakMelakukanText
    private let backButtonText = UIConstants.ManageUnsavedActivityViewConstants.backButtonText
    private let saveButtonText = UIConstants.ManageUnsavedActivityViewConstants.saveButtonText
    private let alertTitle = UIConstants.ManageUnsavedActivityViewConstants.alertTitle
    private let alertMessage = UIConstants.ManageUnsavedActivityViewConstants.alertMessage
    
    init(mode: Mode,
         allActivities: [UnsavedActivity] = [],
         allStudents: [Student] = [],
         onSave: @escaping (UnsavedActivity) -> Void) {
        self.mode = mode
        self.allActivities = allActivities
        self.allStudents = allStudents
        self.onSave = onSave

        switch mode {
        case .add:
            _activityText = State(initialValue: "")
        case .edit(let activity):
            _activityText = State(initialValue: activity.activity)
        }
    }
    
    private var student: Student {
        switch mode {
        case .add(let student, _):
            return student
        case .edit(let activity):
            fatalError("Student information needed for edit mode")
        }
    }
    
    private var selectedDate: Date {
        switch mode {
        case .add(_, let date):
            return date
        case .edit(let activity):
            return activity.createdAt
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(isAddMode ? addActivityTitle : editActivityTitle)
                    .foregroundStyle(labelPrimaryBlack)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    ZStack(alignment: .leading) {
                        if activityText.isEmpty {
                            Text(placeholderText)
                                .foregroundStyle(labelTertiary)
                                .font(.body)
                                .fontWeight(.regular)
                                .padding(.horizontal, 11)
                                .padding(.vertical, verticalPadding)
                        }
                        
                        TextField("", text: $activityText)
                            .foregroundStyle(labelPrimaryBlack)
                            .font(.body)
                            .fontWeight(.regular)
                            .padding(.horizontal, 11)
                            .padding(.vertical, verticalPadding)
                    }
                    .background(cardFieldBG)
                    .cornerRadius(cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(monochrome50, lineWidth: strokeWidth)
                    )
                    
                    if !isAddMode {
                        Toggle(isOn: $isBulkEdit) {
                                Text(bulkEditToggleText)
                                    .foregroundStyle(labelPrimaryBlack)
                                    .font(.body)
                                    .fontWeight(.regular)
                        }
                        .padding(.top, toggleTopPadding)
                    }
                    
                    if isAddMode {
                        Menu {
                            Button(mandiriText) {
                                selectedStatus = .mandiri
                            }
                            Button(dibimbingText) {
                                selectedStatus = .dibimbing
                            }
                            Button(tidakMelakukanText) {
                                selectedStatus = .tidakMelakukan
                            }
                        } label: {
                            HStack(spacing: 9) {
                                Text(getStatusText())
                                Image(systemName: "chevron.up.chevron.down")
                            }
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundColor(labelPrimaryBlack)
                            .padding(.horizontal, menuHorizontalPadding)
                            .padding(.vertical, menuVerticalPadding)
                            .background(statusSheet)
                            .cornerRadius(cornerRadius)
                        }
                    }

                }
                Spacer()
            }
            .padding(.top, topPadding)
            .padding(.horizontal, horizontalPadding)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isAddMode ? addActivityTitle : editActivityTitle)
                        .foregroundStyle(labelPrimaryBlack)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, buttonTopPadding)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text(backButtonText)
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.top, buttonTopPadding)
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
                    .padding(.top, buttonTopPadding)
                }
            }
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func getStatusText() -> String {
        switch selectedStatus {
        case .mandiri:
            return mandiriText
        case .dibimbing:
            return dibimbingText
        case .tidakMelakukan:
            return tidakMelakukanText
        }
    }

    
    private var isAddMode: Bool {
        switch mode {
        case .add: return true
        case .edit: return false
        }
    }
    
    private func saveActivity() {
        if isAddMode {
            saveNewActivity()
        } else {
            saveEditedActivity()
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveNewActivity() {
        let newActivity = UnsavedActivity(
            activity: activityText,
            createdAt: selectedDate,
            status: selectedStatus,
            studentId: student.id
        )
        
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_text_length": activityText.count,
            "status": selectedStatus.rawValue,
            "created_at": selectedDate.timeIntervalSince1970,
            "screen": "add_activity",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        analytics.trackEvent("Activity Created", properties: properties)
        onSave(newActivity)
    }
    
    private func saveEditedActivity() {
        if case .edit(let activity) = mode {
            if isBulkEdit {
                let sameNameActivities = allActivities.filter {
                    $0.activity.lowercased() == activity.activity.lowercased() &&
                    Calendar.current.isDate($0.createdAt, inSameDayAs: activity.createdAt)
                }
                
                for activityToUpdate in sameNameActivities {
                    let updatedActivity = UnsavedActivity(
                        id: activityToUpdate.id,
                        activity: activityText,
                        createdAt: activityToUpdate.createdAt,
                        status: activityToUpdate.status,
                        studentId: activityToUpdate.studentId
                    )
                    onSave(updatedActivity)
                }
            } else {
                let updatedActivity = UnsavedActivity(
                    id: activity.id,
                    activity: activityText,
                    createdAt: activity.createdAt,
                    status: activity.status,
                    studentId: activity.studentId
                )
                onSave(updatedActivity)
            }
        }
    }
}

#Preview {
    ManageUnsavedActivityView(
        mode: .add(.init(fullname: "Rangga Biner", nickname: "Rangga"), .now),
        onSave: { _ in print("saved activity") }
    )
}
