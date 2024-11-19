//
//  MonthlyEditCard.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI

struct MonthlyEditCard: View {
    
    // MARK: - ViewModels
    @StateObject var viewModel = MonthlyEditViewModel()
    
    // MARK: - Constants
    private let backgroundColor = UIConstants.MonthlyEdit.backgroundColor
    private let titleColor = UIConstants.MonthlyEdit.titleColor
    private let dividerColor = UIConstants.MonthlyEdit.dividerColor
    private let spacing = UIConstants.MonthlyEdit.spacing
    private let horizontalPadding = UIConstants.MonthlyEdit.horizontalPadding
    private let cardCornerRadius = UIConstants.MonthlyEdit.cardCornerRadius
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            headerSection
            topDivider
            activitiesSection
            middleDivider
            notesSection
        }
        .padding(.top, UIConstants.MonthlyEdit.topPadding)
        .padding(.bottom, UIConstants.MonthlyEdit.bottomPadding)
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
        .padding(.bottom, UIConstants.MonthlyEdit.titleBottomPadding)
    }
    
    private var topDivider: some View {
        DividerView()
            .padding(.bottom, UIConstants.MonthlyEdit.dividerBottomPadding)
    }
    
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
    
    private var middleDivider: some View {
        DividerView()
            .padding(.vertical, UIConstants.MonthlyEdit.dividerVerticalPadding)
            .padding(.horizontal, horizontalPadding)
    }
    
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
    private struct DividerView: View {
        var body: some View {
            Divider()
                .frame(height: UIConstants.MonthlyEdit.dividerHeight)
                .background(UIConstants.MonthlyEdit.dividerColor)
        }
    }
    

}
