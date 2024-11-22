//  ManageActivityView.swift
//  Gako
//
//  Created by Rangga Biner on 04/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A view for managing the addition and editing of student activities
//  Usage: Use this view to create or edit activities for a student, including status selection
//

import SwiftUI
import Mixpanel

struct ManageActivityView: View {
    // MARK: - Constants
    private let titleColor = UIConstants.ManageActivityView.titleColor
    private let placeholderColor = UIConstants.ManageActivityView.placeholderColor
    private let textColor = UIConstants.ManageActivityView.textColor
    private let textFieldBackground = UIConstants.ManageActivityView.textFieldBackground
    private let borderColor = UIConstants.ManageActivityView.borderColor
    private let statusMenuBackground = UIConstants.ManageActivityView.statusMenuBackground
    private let spacing = UIConstants.ManageActivityView.spacing
    private let innerSpacing = UIConstants.ManageActivityView.innerSpacing
    private let statusMenuSpacing = UIConstants.ManageActivityView.statusMenuSpacing
    private let topPadding = UIConstants.ManageActivityView.topPadding
    private let horizontalPadding = UIConstants.ManageActivityView.horizontalPadding
    private let toolbarTopPadding = UIConstants.ManageActivityView.toolbarTopPadding
    private let cornerRadius = UIConstants.ManageActivityView.cornerRadius
    private let borderWidth = UIConstants.ManageActivityView.borderWidth
    private let textFieldPadding = UIConstants.ManageActivityView.textFieldPadding
    private let statusMenuPadding = UIConstants.ManageActivityView.statusMenuPadding
    private let addActivityTitle = UIConstants.ManageActivityView.addActivityTitle
    private let editActivityTitle = UIConstants.ManageActivityView.editActivityTitle
    private let placeholderText = UIConstants.ManageActivityView.placeholderText
    private let backButtonText = UIConstants.ManageActivityView.backButtonText
    private let saveButtonText = UIConstants.ManageActivityView.saveButtonText
    private let alertTitle = UIConstants.ManageActivityView.alertTitle
    private let alertMessage = UIConstants.ManageActivityView.alertMessage
    private let okButtonText = UIConstants.ManageActivityView.okButtonText
    private let backIcon = UIConstants.ManageActivityView.backIcon
    
    // MARK: - Properties
    @State  var activityText: String
    @State  var showAlert: Bool = false
    @State  var selectedStatus: Status = .dibimbing
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    let onSave: (Activity) async -> Void
    let onUpdate: (Activity) -> Void
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    let mode: Mode
    
    // MARK: - Initialization
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
    
    // MARK: - Body
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
                        .foregroundStyle(.accent)
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
                            .foregroundStyle(.accent)
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
}

// MARK: - Preview
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
