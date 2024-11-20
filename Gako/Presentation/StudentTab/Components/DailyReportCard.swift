//
//  DailyReportCard.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct DailyReportCard: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DailyReportStudent.titleColor
    private let buttonBackground = UIConstants.DailyReportStudent.buttonBackground
    private let buttonTextColor = UIConstants.DailyReportStudent.buttonTextColor
    private let dividerColor = UIConstants.DailyReportStudent.dividerColor
    private let cardBackground = UIConstants.DailyReportStudent.cardBackground
    
    private let cardCornerRadius = UIConstants.DailyReportStudent.cardCornerRadius
    private let buttonSize = UIConstants.DailyReportStudent.buttonSize
    private let horizontalPadding = UIConstants.DailyReportStudent.horizontalPadding
    private let verticalPadding = UIConstants.DailyReportStudent.verticalPadding
    private let bottomPadding = UIConstants.DailyReportStudent.bottomPadding
    private let spacing = UIConstants.DailyReportStudent.spacing
    private let dividerHeight = UIConstants.DailyReportStudent.dividerHeight
    private let dividerVerticalPadding = UIConstants.DailyReportStudent.dividerVerticalPadding
    private let dividerTopPadding = UIConstants.DailyReportStudent.dividerTopPadding
    
    private let shareIcon = UIConstants.DailyReportStudent.shareIcon
    private let alertTitle = UIConstants.DailyReportStudent.alertTitle
    private let emptyAlertMessage = UIConstants.DailyReportStudent.emptyAlertMessage
    private let okButtonText = UIConstants.DailyReportStudent.okButtonText
    
    // MARK: - Properties
    let activities: [Activity]
    let notes: [Note]
    let student: Student
    let date: Date
    
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let onShareTapped: (Date) -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    
    @State private var showEmptyAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            headerView
            divider
            activitySection
            notesDivider
            notesSection
        }
        .padding(.top, verticalPadding)
        .padding(.bottom, bottomPadding)
        .background(cardBackground)
        .cornerRadius(cardCornerRadius)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .alert(alertTitle, isPresented: $showEmptyAlert) {
            Button(okButtonText, role: .cancel) { }
        } message: {
            Text(emptyAlertMessage)
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            Text(DateFormatHelper.indonesianFormattedDate(date))
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(titleColor)
            
            Spacer()
            
            shareButton
        }
        .padding(.horizontal, horizontalPadding)
    }
    
    private var shareButton: some View {
        Button(action: validateAndShare) {
            ZStack {
                Circle()
                    .frame(width: buttonSize)
                    .foregroundStyle(buttonBackground)
                Image(systemName: shareIcon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(buttonTextColor)
            }
        }
    }
    
    private var divider: some View {
        Divider()
            .frame(height: dividerHeight)
            .background(dividerColor)
            .padding(.bottom, dividerVerticalPadding)
    }
    
    private var activitySection: some View {
        ActivitySection(
            activities: activities,
            onDeleteActivity: onDeleteActivity,
            onStatusChanged: { activity, newStatus in
                Task {
                    await onUpdateActivityStatus(activity, newStatus)
                }
            }
        )
        .disabled(true)
        .padding(.horizontal, horizontalPadding)
    }
    
    private var notesDivider: some View {
        Divider()
            .frame(height: dividerHeight)
            .background(dividerColor)
            .padding(.bottom, dividerVerticalPadding)
            .padding(.top, dividerTopPadding)
    }
    
    private var notesSection: some View {
        NoteSection(
            notes: notes,
            onEditNote: onEditNote,
            onDeleteNote: onDeleteNote,
            onAddNote: onAddNote
        )
        .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Actions
    private func validateAndShare() {
        if activities.isEmpty && notes.isEmpty {
            showEmptyAlert = true
            return
        }
        onShareTapped(date)
    }
}



#Preview {
    DailyReportCard(
        activities: [
            .init(activity: "Senam", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(activity: "Makan ikan", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
        ],
        notes: [
            .init(note: "Anak sangat aktif hari ini", student: .init(fullname: "Rangga Biner", nickname: "Rangga")),
            .init(note: "Keren banget dah wadidaw dbashjfbhjabfhjabjfhbhjasbfhjsabfhkasdmlfmakldmsaklfmskljsadnjkfnsaf", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
        ],
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        date: .now,
        onAddNote: { print("added note") },
        onAddActivity: { print("added activity")},
        onDeleteActivity: { _ in print("deleted activity")},
        onEditNote: { _ in print("edited note")},
        onDeleteNote: { _ in print("deleted note") },
        onShareTapped: { _ in print("shared")},
        onUpdateActivityStatus: { _, _ in print("updated activity")}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
