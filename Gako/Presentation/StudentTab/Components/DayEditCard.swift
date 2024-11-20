//
//  DayEditCard.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A card view component for editing daily student activities and notes
//  Usage: Use this view to display and edit daily student records
//

import SwiftUI

struct DayEditCard: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DayEditCard.titleColor
    private let backgroundColor = UIConstants.DayEditCard.backgroundColor
    private let emptyTextColor = UIConstants.DayEditCard.emptyTextColor
    private let dividerColor = UIConstants.DayEditCard.dividerColor
    private let cardCornerRadius = UIConstants.DayEditCard.cardCornerRadius
    private let spacing = UIConstants.DayEditCard.spacing
    private let horizontalPadding = UIConstants.DayEditCard.horizontalPadding
    private let verticalPadding = UIConstants.DayEditCard.verticalPadding
    private let dividerHeight = UIConstants.DayEditCard.dividerHeight
    private let dividerVerticalPadding = UIConstants.DayEditCard.dividerVerticalPadding
    
    // MARK: - Properties
    let date: Date
    let activities: [Activity]
    let notes: [Note]
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    @Binding var editedNotes: [UUID: (String, Date)]
    let onDeleteActivity: (Activity) -> Void
    let onDeleteNote: (Note) -> Void
    @State var newActivities: [(id: UUID, activity: String, status: Status)] = []
    @State var newNotes: [(id: UUID, note: String)] = []
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            headerView
            activitiesSection
            addActivityButton
            divider
            notesSection
            addNoteButton
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(backgroundColor)
        .cornerRadius(cardCornerRadius)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    // MARK: - Subview
    private var headerView: some View {
        Text(DateFormatHelper.indonesianFormattedDate(date))
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(titleColor)
    }
    
    // MARK: - Subview
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(UIConstants.DayEdit.activitySectionTitle)
                .font(.callout)
                .fontWeight(.bold)
            if activities.isEmpty && newActivities.isEmpty {
                Text(UIConstants.DayEdit.emptyActivityText)
                    .foregroundColor(emptyTextColor)
            } else {
                existingActivitiesView
                newActivitiesView
            }
        }
    }
    
    // MARK: - Subview
    private var existingActivitiesView: some View {
        ForEach(activities) { activity in
            DayEditActivityRow(
                activity: activity,
                index: activities.firstIndex(of: activity)! + 1,
                editedActivities: $editedActivities,
                date: date,
                onDelete: onDeleteActivity
            )
        }
    }
    
    // MARK: - Subview
    private var newActivitiesView: some View {
        ForEach(newActivities, id: \.id) { newActivity in
            DayEditNewActivityRow(
                newActivity: newActivity,
                index: activities.count + newActivities.firstIndex(where: { $0.id == newActivity.id })! + 1,
                editedActivities: $editedActivities,
                date: date,
                onDelete: { removeNewActivity(id: newActivity.id) }
            )
        }
    }
    
    // MARK: - Subview
    private var addActivityButton: some View {
        AddItemButton(
            onTapAction: addNewActivity,
            bgColor: .buttonOncard,
            text: UIConstants.DayEdit.addButtonText
        )
    }
    
    // MARK: - Subview
    private var divider: some View {
        Divider()
            .frame(height: dividerHeight)
            .background(dividerColor)
            .padding(.vertical, dividerVerticalPadding)
    }
    
    // MARK: - Subview
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(UIConstants.DayEdit.notesSectionTitle)
                .font(.callout)
                .fontWeight(.bold)
            
            if notes.isEmpty && newNotes.isEmpty {
                Text(UIConstants.DayEdit.emptyNotesText)
                    .foregroundColor(emptyTextColor)
            } else {
                existingNotesView
                newNotesView
            }
        }
    }
    
    // MARK: - Subview
    private var existingNotesView: some View {
        ForEach(notes) { note in
            DayEditNoteRow(
                note: note,
                editedNotes: $editedNotes,
                date: date,
                onDelete: onDeleteNote
            )
        }
    }
    
    // MARK: - Subview
    private var newNotesView: some View {
        ForEach(newNotes, id: \.id) { newNote in
            DayEditNewNoteRow(
                newNote: newNote,
                editedNotes: $editedNotes,
                date: date,
                onDelete: { removeNewNote(id: newNote.id) }
            )
        }
    }
    
    // MARK: - Subview
    private var addNoteButton: some View {
        AddItemButton(
            onTapAction: addNewNote,
            bgColor: .buttonOncard,
            text: UIConstants.DayEdit.addButtonText
        )
    }
    
    // MARK: - Actions
    private func addNewActivity() {
        let newId = UUID()
        newActivities.append((id: newId, activity: "", status: .tidakMelakukan))
        editedActivities[newId] = ("", .tidakMelakukan, date)
    }
}
