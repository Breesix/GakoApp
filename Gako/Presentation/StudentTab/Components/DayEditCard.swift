//
//  DayEditCard.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct DayEditCard: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DayEdit.titleColor
    private let backgroundColor = UIConstants.DayEdit.backgroundColor
    private let emptyTextColor = UIConstants.DayEdit.emptyTextColor
    private let dividerColor = UIConstants.DayEdit.dividerColor
    private let cardCornerRadius = UIConstants.DayEdit.cardCornerRadius
    private let spacing = UIConstants.DayEdit.spacing
    private let horizontalPadding = UIConstants.DayEdit.horizontalPadding
    private let verticalPadding = UIConstants.DayEdit.verticalPadding
    private let dividerHeight = UIConstants.DayEdit.dividerHeight
    private let dividerVerticalPadding = UIConstants.DayEdit.dividerVerticalPadding
    
    // MARK: - Properties
    let date: Date
    let activities: [Activity]
    let notes: [Note]
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    @Binding var editedNotes: [UUID: (String, Date)]
    let onDeleteActivity: (Activity) -> Void
    let onDeleteNote: (Note) -> Void
    
    @State private var newActivities: [(id: UUID, activity: String, status: Status)] = []
    @State private var newNotes: [(id: UUID, note: String)] = []
    
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
    
    // MARK: - Subviews
    private var headerView: some View {
        Text(DateFormatHelper.indonesianFormattedDate(date))
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(titleColor)
    }
    
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
    
    private var addActivityButton: some View {
        AddItemButton(
            onTapAction: addNewActivity,
            bgColor: .buttonOncard,
            text: UIConstants.DayEdit.addButtonText
        )
    }
    
    private var divider: some View {
        Divider()
            .frame(height: dividerHeight)
            .background(dividerColor)
            .padding(.vertical, dividerVerticalPadding)
    }
    
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
    
    private func removeNewActivity(id: UUID) {
        newActivities.removeAll(where: { $0.id == id })
        editedActivities.removeValue(forKey: id)
    }
    
    private func addNewNote() {
        let newId = UUID()
        newNotes.append((id: newId, note: ""))
        editedNotes[newId] = ("", date)
    }
    
    private func removeNewNote(id: UUID) {
        newNotes.removeAll(where: { $0.id == id })
        editedNotes.removeValue(forKey: id)
    }
}
