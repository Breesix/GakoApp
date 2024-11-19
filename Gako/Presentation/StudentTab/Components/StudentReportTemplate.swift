//
//  StudentReportTemplate.swift
//  Breesix
//
//  Created by Akmal Hakim on 30/10/24.
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
    // Dimensions
    let a4Width = UIConstants.DailyReportTemplate.a4Width
    let a4Height = UIConstants.DailyReportTemplate.a4Height
    private let logoWidth = UIConstants.DailyReportTemplate.logoWidth
    private let studentImageSize = UIConstants.DailyReportTemplate.studentImageSize
    private let watermarkSize = UIConstants.DailyReportTemplate.watermarkSize
    private let studentInfoHeight = UIConstants.DailyReportTemplate.studentInfoHeight
    private let borderWidth = UIConstants.DailyReportTemplate.borderWidth
    private let borderInset = UIConstants.DailyReportTemplate.borderInset
    private let cornerRadius = UIConstants.DailyReportTemplate.cornerRadius
    private let spacing = UIConstants.DailyReportTemplate.spacing
    private let headerSpacing = UIConstants.DailyReportTemplate.headerSpacing
    
    // Section Titles
    private let reportTitle = UIConstants.DailyReportTemplate.reportTitle
    private let summaryTitle = UIConstants.DailyReportTemplate.summaryTitle
    private let activityTitle = UIConstants.DailyReportTemplate.activityTitle
    private let statusTitle = UIConstants.DailyReportTemplate.statusTitle
    private let notesTitle = UIConstants.DailyReportTemplate.notesTitle
    
    // Empty States
    private let noSummaryText = UIConstants.DailyReportTemplate.noSummaryText
    
    // Footer
    private let sharedText = UIConstants.DailyReportTemplate.sharedText
    private let pageText = UIConstants.DailyReportTemplate.pageText
    private let fromText = UIConstants.DailyReportTemplate.fromText
    
    // Images
    private let logoImage = UIConstants.DailyReportTemplate.logoImage
    private let watermarkImage = UIConstants.DailyReportTemplate.watermarkImage
    private let defaultProfileImage = UIConstants.DailyReportTemplate.defaultProfileImage
    
    // Colors
    private let headerTextColor = UIConstants.DailyReportTemplate.headerTextColor
    private let primaryTextColor = UIConstants.DailyReportTemplate.primaryTextColor
    private let secondaryTextColor = UIConstants.DailyReportTemplate.secondaryTextColor
    private let borderColor = UIConstants.DailyReportTemplate.borderColor
    private let backgroundColor = UIConstants.DailyReportTemplate.backgroundColor
    private let activityHeaderColor = UIConstants.DailyReportTemplate.activityHeaderColor
    private let footerTextColor = UIConstants.DailyReportTemplate.footerTextColor
    private let watermarkColor = UIConstants.DailyReportTemplate.watermarkColor
    private let profileImageColor = UIConstants.DailyReportTemplate.profileImageColor
    
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

extension DailyReportTemplate {
    func reportPage(pageIndex: Int) -> some View {
        VStack(spacing: 0) {
            reportHeader
            
            if pageIndex == 0 {
                studentInfo
                summarySection
                if !activities.isEmpty {
                    activitySection(Array(activities.prefix(6)))
                }
            } else {
                let startIndex = 5 + (pageIndex - 1) * 10
                let pageActivities = Array(activities.dropFirst(startIndex).prefix(10))
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






#Preview {
    DailyReportTemplate(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), activities: [.init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], notes: [.init(note: "Anak ini baik banget", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], date: .now)
}
