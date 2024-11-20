//
//  EditActivityRow.swift
//  Gako
//
//  Created by Rangga Biner on 10/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A row component for displaying and editing student activities with status control
//  Usage: Use this view to manage individual activity entries with editing and deletion capabilities
//

import SwiftUI
import Mixpanel

struct EditActivityRow: View {
    // MARK: - Constants
    private let deleteButtonSize = UIConstants.EditActivityRow.deleteButtonSize
    private let rowSpacing = UIConstants.EditActivityRow.rowSpacing
    private let activityPadding = UIConstants.EditActivityRow.activityPadding
    private let cornerRadius = UIConstants.EditActivityRow.cornerRadius
    private let strokeWidth = UIConstants.EditActivityRow.strokeWidth
    private let statusPickerSpacing = UIConstants.EditActivityRow.statusPickerSpacing
    private let deleteAlertTitle = UIConstants.EditActivityRow.deleteAlertTitle
    private let deleteAlertMessage = UIConstants.EditActivityRow.deleteAlertMessage
    private let deleteButtonText = UIConstants.EditActivityRow.deleteButtonText
    private let cancelButtonText = UIConstants.EditActivityRow.cancelButtonText
    private let symbol = UIConstants.EditActivityRow.symbol
    
    // MARK: - Properties
    @Binding var activity: Activity
    let activityIndex: Int
    let student: Student
    let onAddActivity: () -> Void
    let onEdit: (Activity) -> Void
    let onDelete: () -> Void
    let onDeleteActivity: (Activity) -> Void
    let onStatusChanged: (Activity, Status) -> Void
    let analytics = InputAnalyticsTracker.shared
    @State var showDeleteAlert = false
    @State var status: Status
    
    // MARK: - Initialization
    init(activity: Binding<Activity>,
         activityIndex: Int,
         student: Student,
         onAddActivity: @escaping () -> Void,
         onEdit: @escaping (Activity) -> Void,
         onDelete: @escaping () -> Void,
         onDeleteActivity: @escaping (Activity) -> Void,
         onStatusChanged: @escaping (Activity, Status) -> Void) {
        self._activity = activity
        self.activityIndex = activityIndex
        self.student = student
        self.onAddActivity = onAddActivity
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onDeleteActivity = onDeleteActivity
        self.onStatusChanged = onStatusChanged
        _status = State(initialValue: activity.wrappedValue.status)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
            activitySection
            activityTitle
            statusPicker
        }
        .alert(deleteAlertTitle,
               isPresented: $showDeleteAlert) {
            Button(deleteButtonText,
                   role: .destructive,
                   action: handleDeleteConfirmation)
            Button(cancelButtonText,
                   role: .cancel) { }
        } message: {
            Text(deleteAlertMessage)
        }
        .onAppear {
            status = activity.status
        }
    }
    
    // MARK: - Subview
    private var activitySection: some View {
        HStack {
            Text("Aktivitas \(activityIndex + 1)")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimaryBlack)
            Spacer()
            Button(action: handleDeleteTap) {
                ZStack {
                    Circle()
                        .frame(width: deleteButtonSize)
                        .foregroundStyle(.buttonDestructiveOnCard)
                    Image(systemName: symbol)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.destructiveOnCardLabel)
                }
            }
        }
    }
    
    // MARK: - Subview
    private var activityTitle: some View {
        Text(activity.activity)
            .font(.subheadline)
            .fontWeight(.regular)
            .foregroundStyle(.labelPrimaryBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(activityPadding)
            .background(.monochrome100)
            .cornerRadius(cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(.noteStroke, lineWidth: strokeWidth)
            }
            .onTapGesture {
                onEdit(activity)
            }
    }
    
    // MARK: - Subview
    private var statusPicker: some View {
        HStack(spacing: statusPickerSpacing) {
            StatusPicker(status: $status) { newStatus in
                handleStatusChange(newStatus)
            }
        }
    }
}
   
// MARK: - Preview
#Preview {
    EditActivityRow(activity: .constant(.init(
        activity: "Menjahit",
        createdAt: .now, student: .init(fullname: "Rangga Biner", nickname: "rangga")
    )), activityIndex: 0, student: .init(fullname: "Rangga bienr", nickname: "rangga"), onAddActivity: { print("added activity") }, onEdit:  { _ in print("edit activity") }, onDelete: { print("deleted") }, onDeleteActivity: { _ in print("deleted activity") }, onStatusChanged: { _,_  in print("status changed")})
}

