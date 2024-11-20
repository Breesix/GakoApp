//
//  StudentReportTemplate.swift
//  Gako
//
//  Created by Akmal Hakim on 30/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A template component for generating student daily activity reports in A4 format
//  Usage: Use this view to create printable/shareable daily student reports with activities and notes
//

import SwiftUI

struct DailyReportTemplate: View {
    // MARK: - Properties
    let student: Student
    let activities: [Activity]
    let notes: [Note]
    let date: Date
    @State private var numberOfPages: Int = 1
    
    // MARK: - Constants
    let a4Width = UIConstants.DailyReportTemplate.a4Width
    let a4Height = UIConstants.DailyReportTemplate.a4Height
    let logoWidth = UIConstants.DailyReportTemplate.logoWidth
    let studentImageSize = UIConstants.DailyReportTemplate.studentImageSize
    let watermarkSize = UIConstants.DailyReportTemplate.watermarkSize
    let studentInfoHeight = UIConstants.DailyReportTemplate.studentInfoHeight
    let borderWidth = UIConstants.DailyReportTemplate.borderWidth
    let borderInset = UIConstants.DailyReportTemplate.borderInset
    let cornerRadius = UIConstants.DailyReportTemplate.cornerRadius
    let spacing = UIConstants.DailyReportTemplate.spacing
    let headerSpacing = UIConstants.DailyReportTemplate.headerSpacing
    let reportTitle = UIConstants.DailyReportTemplate.reportTitle
    let summaryTitle = UIConstants.DailyReportTemplate.summaryTitle
    let activityTitle = UIConstants.DailyReportTemplate.activityTitle
    let statusTitle = UIConstants.DailyReportTemplate.statusTitle
    let notesTitle = UIConstants.DailyReportTemplate.notesTitle
    let noSummaryText = UIConstants.DailyReportTemplate.noSummaryText
    let sharedText = UIConstants.DailyReportTemplate.sharedText
    let pageText = UIConstants.DailyReportTemplate.pageText
    let fromText = UIConstants.DailyReportTemplate.fromText
    let logoImage = UIConstants.DailyReportTemplate.logoImage
    let watermarkImage = UIConstants.DailyReportTemplate.watermarkImage
    let defaultProfileImage = UIConstants.DailyReportTemplate.defaultProfileImage
    let headerTextColor = UIConstants.DailyReportTemplate.headerTextColor
    let primaryTextColor = UIConstants.DailyReportTemplate.primaryTextColor
    let secondaryTextColor = UIConstants.DailyReportTemplate.secondaryTextColor
    let borderColor = UIConstants.DailyReportTemplate.borderColor
    let backgroundColor = UIConstants.DailyReportTemplate.backgroundColor
    let activityHeaderColor = UIConstants.DailyReportTemplate.activityHeaderColor
    let footerTextColor = UIConstants.DailyReportTemplate.footerTextColor
    let watermarkColor = UIConstants.DailyReportTemplate.watermarkColor
    let profileImageColor = UIConstants.DailyReportTemplate.profileImageColor
    
    // MARK: - Body
    var body: some View {
        TabView {
            ForEach(0..<calculateRequiredPages(), id: \.self) { pageIndex in
                reportPage(pageIndex: pageIndex)
                    .frame(width: a4Width, height: a4Height)
                    .background(backgroundColor)
            }
        }
        .tabViewStyle(.page)
    }
}

// MARK: - Preview
#Preview {
    DailyReportTemplate(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), activities: [.init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], notes: [.init(note: "Anak ini baik banget", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], date: .now)
}
