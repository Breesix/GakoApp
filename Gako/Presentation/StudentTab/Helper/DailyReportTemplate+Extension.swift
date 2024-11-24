//
//  DailyReportTemplate+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides layout and section components for DailyReportTemplate
//  Usage: Contains view builders for different sections of the daily report template
//

import Foundation
import SwiftUI

extension DailyReportTemplate {
    func reportPage(pageIndex: Int) -> some View {
        VStack(spacing: 0) {
            reportHeader
            
            if pageIndex == 0 {
                studentInfo
                summarySection
                
                let summary = student.summaries.first(where: { Calendar.current.isDate($0.createdAt, inSameDayAs: date) })
                let summaryText = summary?.summary ?? noSummaryText
                let summaryTextHeight = summaryText.height(withConstrainedWidth: a4Width - 40)
                
                let headerHeight: CGFloat = 80
                let summaryTitleHeight: CGFloat = 30
                let summaryPadding: CGFloat = 40
                let totalSummaryHeight = summaryTitleHeight + summaryTextHeight + summaryPadding
                
                let availableHeight = a4Height - headerHeight - studentInfoHeight - totalSummaryHeight - 100
                let activityRowHeight: CGFloat = 60
                let maxActivitiesForFirstPage = max(0, Int(availableHeight / activityRowHeight))
                
                if !activities.isEmpty && maxActivitiesForFirstPage > 0 {
                    activitySection(Array(activities.prefix(maxActivitiesForFirstPage)))
                }
            } else {
                let availableHeight = a4Height - 160
                let activityRowHeight: CGFloat = 60
                let maxActivitiesPerPage = Int(availableHeight / activityRowHeight)
                
                let startIndex = getFirstPageActivityCount() + (pageIndex - 1) * maxActivitiesPerPage
                let pageActivities = Array(activities.dropFirst(startIndex).prefix(maxActivitiesPerPage))
                
                if !pageActivities.isEmpty {
                    activitySection(pageActivities)
                }
            }
            
            Spacer()
            reportFooter(pageNumber: pageIndex + 1)
        }
    }
    
    var reportHeader: some View {
        HStack {
            Image(logoImage)
                .resizable()
                .scaledToFit()
                .frame(width: logoWidth)
            Spacer()
            VStack(alignment: .trailing) {
                Text(reportTitle)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(headerTextColor)
                Text(indonesianFormattedDate(date: date))
                    .font(.body)
                    .italic()
                    .foregroundStyle(secondaryTextColor)
            }
        }
        .padding()
    }
    
    var studentInfo: some View {
        ZStack {
            HStack(spacing: headerSpacing) {
                if let imageData = student.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: studentImageSize, height: studentImageSize)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .inset(by: borderInset)
                                .stroke(.accent, lineWidth: borderWidth)
                        )
                } else {
                    Image(systemName: defaultProfileImage)
                        .resizable()
                        .frame(width: studentImageSize, height: studentImageSize)
                        .foregroundColor(profileImageColor)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading) {
                    Text(student.fullname)
                        .font(.title3)
                        .bold()
                        .foregroundStyle(primaryTextColor)
                    Text(student.nickname)
                        .font(.body)
                        .foregroundStyle(primaryTextColor)
                }
                Spacer()
            }
            
            HStack {
                Spacer()
                Image(watermarkImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: watermarkSize, height: watermarkSize)
                    .foregroundColor(watermarkColor)
                    .padding(.trailing)
            }
        }
        .padding(.leading)
        .frame(height: studentInfoHeight)
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .inset(by: borderInset)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .padding(.horizontal)
    }
    
    var summarySection: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack {
                Text(summaryTitle)
                    .font(.headline)
                    .foregroundStyle(primaryTextColor)
                Spacer()
            }
            
            if let summary = student.summaries.first(where: { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }) {
                Text(summary.summary)
                    .font(.body)
                    .foregroundStyle(primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.monochrome100)
                    .cornerRadius(cornerRadius)
            } else {
                Text(noSummaryText)
                    .font(.body)
                    .foregroundStyle(primaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.monochrome100)
                    .cornerRadius(cornerRadius)
            }
        }
        .padding()
    }
    
    func activitySection(_ activities: [Activity]) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            VStack(spacing: 0) {
                HStack {
                    Text(activityTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Spacer()
                    Text(statusTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding()
                .background(activityHeaderColor)
                
                ForEach(activities) { activity in
                    HStack {
                        Text(activity.activity)
                            .foregroundStyle(primaryTextColor)
                        Spacer()
                        Text(activity.status.rawValue)
                            .foregroundStyle(primaryTextColor)
                    }
                    .padding()
                    Divider()
                }
            }
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .inset(by: borderInset)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .padding()
    }
    
    private func getFirstPageActivityCount() -> Int {
        let summary = student.summaries.first(where: { Calendar.current.isDate($0.createdAt, inSameDayAs: date) })
        let summaryText = summary?.summary ?? noSummaryText
        let summaryTextHeight = summaryText.height(withConstrainedWidth: a4Width - 40)
        
        let headerHeight: CGFloat = 80
        let summaryTitleHeight: CGFloat = 30
        let summaryPadding: CGFloat = 40
        let totalSummaryHeight = summaryTitleHeight + summaryTextHeight + summaryPadding
        
        let availableHeight = a4Height - headerHeight - studentInfoHeight - totalSummaryHeight - 100
        let activityRowHeight: CGFloat = 60
        
        return max(0, Int(availableHeight / activityRowHeight))
    }
    
    func reportFooter(pageNumber: Int) -> some View {
        HStack {
            Text(sharedText)
                .font(.caption)
                .foregroundColor(footerTextColor)
            Spacer()
            Text("\(pageText) \(pageNumber) \(fromText) \(calculateRequiredPages())")
                .font(.caption)
                .foregroundColor(footerTextColor)
        }
        .padding()
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: .body)
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
}
