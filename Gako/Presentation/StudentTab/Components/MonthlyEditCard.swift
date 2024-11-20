//
//  MonthlyEditCard.swift
//  Gako
//
//  Created by Rangga Biner on 10/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A comprehensive card component for editing monthly student records
//  Usage: Use this view to manage both activities and notes for a specific date
//

import SwiftUI

struct MonthlyEditCard: View {
    // MARK: - ViewModels
    @StateObject var viewModel = MonthlyEditViewModel()
    
    // MARK: - Constants
    private let backgroundColor = UIConstants.MonthlyEditCard.backgroundColor
    private let titleColor = UIConstants.MonthlyEditCard.titleColor
    private let dividerColor = UIConstants.MonthlyEditCard.dividerColor
    private let spacing = UIConstants.MonthlyEditCard.spacing
    private let horizontalPadding = UIConstants.MonthlyEditCard.horizontalPadding
    private let cardCornerRadius = UIConstants.MonthlyEditCard.cardCornerRadius
    private let topPadding = UIConstants.MonthlyEditCard.topPadding
    private let bottomPadding = UIConstants.MonthlyEditCard.bottomPadding
    private let titleBottomPadding = UIConstants.MonthlyEditCard.titleBottomPadding
    private let dividerBottomPadding = UIConstants.MonthlyEditCard.dividerBottomPadding
    private let dividerVerticalPadding = UIConstants.MonthlyEditCard.dividerVerticalPadding
    private let dividerHeight = UIConstants.MonthlyEditCard.dividerHeight
    
    // MARK: - Properties
    let date: Date
    let activities: [Activity]
    let notes: [Note]
    let student: Student
    @Binding var selectedStudent: Student?
    @Binding var isAddingNewActivity: Bool
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    @Binding var editedNotes: [UUID: (String, Date)]
    let onDeleteActivity: (Activity) -> Void
    let onDeleteNote: (Note) -> Void
    let onActivityUpdate: (Activity) -> Void
    let onAddActivity: () -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onEditNote: (Note) -> Void
    let onAddNote: (String) -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            headerSection
            topDivider
            activitiesSection
            middleDivider
            notesSection
        }
        .padding(.top, topPadding)
        .padding(.bottom, bottomPadding)
        .background(backgroundColor)
        .cornerRadius(cardCornerRadius)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    // MARK: - Subviews
    private var headerSection: some View {
        HStack {
            Text(DateFormatHelper.indonesianFormattedDate(date))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(titleColor)
            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.bottom, titleBottomPadding)
    }
    
    // MARK: - Subview
    private var topDivider: some View {
        dividerView
            .padding(.bottom, dividerBottomPadding)
    }
    
    // MARK: - Subview
    private var activitiesSection: some View {
        EditActivitySection(
            student: student,
            selectedStudent: $selectedStudent,
            isAddingNewActivity: $isAddingNewActivity,
            activities: activities,
            onActivityUpdate: onActivityUpdate,
            onDeleteActivity: onDeleteActivity,
            allActivities: activities,
            allStudents: [student],
            onStatusChanged: handleStatusChange,
            onAddActivity: onAddActivity
        )
        .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Subview
    private var middleDivider: some View {
        dividerView
            .padding(.vertical, dividerVerticalPadding)
            .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Subview
    private var notesSection: some View {
        EditNoteSection(
            notes: notes,
            onEditNote: onEditNote,
            onDeleteNote: onDeleteNote,
            onAddNote: { onAddNote("") }
        )
        .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Helper Views
    private var dividerView: some View {
            Divider()
                .frame(height: dividerHeight)
                .background(dividerColor)
    }
}

// MARK: - Preview
#Preview {
    MonthlyEditCard(
        date: Date(),
        activities: [
            .init(activity: "sample", student: .init(fullname: "Rangga", nickname: "biner")),
        ],
        notes: [
            .init(note: "sample", student: .init(fullname: "Rangga", nickname: "biner"))
        ],
        student: .init(fullname: "Rangga", nickname: "biner"),
        selectedStudent: .constant(nil),
        isAddingNewActivity: .constant(false),
        editedActivities: .constant([:]),
        editedNotes: .constant([:]),
        onDeleteActivity: { _ in },
        onDeleteNote: { _ in },
        onActivityUpdate: { _ in },
        onAddActivity: {},
        onUpdateActivityStatus: { _, _ in },
        onEditNote: { _ in },
        onAddNote: { _ in }
    )
    .padding()
}
