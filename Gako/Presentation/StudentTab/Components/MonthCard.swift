//
//  MonthCard.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A card component that displays monthly activity summary
//  Usage: Use this view to show month-based navigation and activity count
//

import SwiftUI

struct MonthCard: View {
    // MARK: - Constants
    private let documentIcon = UIConstants.MonthCard.documentIcon
    private let monthNavigationIcon = UIConstants.MonthCard.monthNavigationIcon
    private let monthCardBackground = UIConstants.MonthCard.monthCardBackground
    private let monthCardText = UIConstants.MonthCard.monthCardText
    private let monthCardCornerRadius = UIConstants.MonthCard.monthCardCornerRadius

    // MARK: - Properties
    let date: Date
    let activitiesCount: Int
    let hasActivities: Bool

    // MARK: - Body
    var body: some View {
        monthSection
    }
    
    // MARK: - Subview
    private var monthSection: some View {
        HStack {
            HStack {
                Image(systemName: documentIcon)
                Text(monthYearString)
            }
            Spacer()
            Image(systemName: monthNavigationIcon)
                .fontWeight(.medium)
                .font(.body)
        }
        .font(.body)
        .fontWeight(.semibold)
        .foregroundColor(monthCardText)
        .padding()
        .background(monthCardBackground)
        .cornerRadius(monthCardCornerRadius)
    }
}
