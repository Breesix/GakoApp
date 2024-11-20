//
//  DailyReportCard.swift
//  Gako
//
//  Created by Akmal Hakim on 07/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom view component that displays a daily report card containing student activities
//  Usage: Implement this component to display a comprehensive daily report
//

import SwiftUI

struct DailyReportCard: View {
    // MARK: - Constants
    private let titleColor = UIConstants.DailyReport.titleColor
    private let buttonBackground = UIConstants.DailyReport.buttonBackground
    private let buttonTextColor = UIConstants.DailyReport.buttonTextColor
    private let dividerColor = UIConstants.DailyReport.dividerColor
    private let cardBackground = UIConstants.DailyReport.cardBackground
    private let cardCornerRadius = UIConstants.DailyReport.cardCornerRadius
    private let buttonSize = UIConstants.DailyReport.buttonSize
    private let horizontalPadding = UIConstants.DailyReport.horizontalPadding
    private let verticalPadding = UIConstants.DailyReport.verticalPadding
    private let bottomPadding = UIConstants.DailyReport.bottomPadding
    private let spacing = UIConstants.DailyReport.spacing
    private let dividerHeight = UIConstants.DailyReport.dividerHeight
    private let dividerVerticalPadding = UIConstants.DailyReport.dividerVerticalPadding
    private let dividerTopPadding = UIConstants.DailyReport.dividerTopPadding
    private let shareIcon = UIConstants.DailyReport.shareIcon
    private let alertTitle = UIConstants.DailyReport.alertTitle
    private let emptyAlertMessage = UIConstants.DailyReport.emptyAlertMessage
    private let okButtonText = UIConstants.DailyReport.okButtonText
    
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
    @State var showEmptyAlert = false
    
    // MARK: - Body
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
    
    // MARK: - Subview
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
    
    // MARK: - Subview
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
    
    // MARK: - Subview
    private var divider: some View {
        Divider()
            .frame(height: dividerHeight)
            .background(dividerColor)
            .padding(.bottom, dividerVerticalPadding)
    }
    
    // MARK: - Subview
    private var activitySection: some View {
        ActivitySection(
            activities: activities,
            onStatusChanged: { activity, newStatus in
                Task {
                    await onUpdateActivityStatus(activity, newStatus)
                }
            }
        )
        .disabled(true)
        .padding(.horizontal, horizontalPadding)
    }
    
    // MARK: - Subview
    private var notesDivider: some View {
        Divider()
            .frame(height: dividerHeight)
            .background(dividerColor)
            .padding(.bottom, dividerVerticalPadding)
            .padding(.top, dividerTopPadding)
    }
    
    // MARK: - Subview
    private var notesSection: some View {
        NoteSection(
            notes: notes,
            onEditNote: onEditNote,
            onDeleteNote: onDeleteNote,
            onAddNote: onAddNote
        )
        .padding(.horizontal, horizontalPadding)
    }
}

// MARK: - Preview
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
