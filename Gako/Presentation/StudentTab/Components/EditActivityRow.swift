//
//  EditActivityRow.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI
import Mixpanel

struct EditActivityRow: View {
    // MARK: - Constants
    private let deleteButtonSize = UIConstants.EditActivity.deleteButtonSize
    private let rowSpacing = UIConstants.EditActivity.rowSpacing
    private let activityPadding = UIConstants.EditActivity.activityPadding
    private let cornerRadius = UIConstants.EditActivity.cornerRadius
    private let strokeWidth = UIConstants.EditActivity.strokeWidth
    private let statusPickerSpacing = UIConstants.EditActivity.statusPickerSpacing
    private let deleteAlertTitle = UIConstants.EditActivity.deleteAlertTitle
    private let deleteAlertMessage = UIConstants.EditActivity.deleteAlertMessage
    private let deleteButtonText = UIConstants.EditActivity.deleteButtonText
    private let cancelButtonText = UIConstants.EditActivity.cancelButtonText
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: rowSpacing) {
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
                        Image(systemName: "trash.fill")
                            .font(.subheadline)
                            .fontWeight(.regular)
                            .foregroundStyle(.destructiveOnCardLabel)
                    }
                }
            }
            
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

            HStack(spacing: statusPickerSpacing) {
                StatusPicker(status: $status) { newStatus in
                    handleStatusChange(newStatus)
                }
            }
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
}
    
#Preview {
    EditActivityRow(activity: .constant(.init(
        activity: "Menjahit",
        createdAt: .now, student: .init(fullname: "Rangga Biner", nickname: "rangga")
    )), activityIndex: 0, student: .init(fullname: "Rangga bienr", nickname: "rangga"), onAddActivity: { print("added activity") }, onEdit:  { _ in print("edit activity") }, onDelete: { print("deleted") }, onDeleteActivity: { _ in print("deleted activity") }, onStatusChanged: { _,_  in print("status changed")})
}

