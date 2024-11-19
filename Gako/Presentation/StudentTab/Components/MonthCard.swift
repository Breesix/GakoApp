//
//  MonthCard.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct MonthCard: View {
    let date: Date
    let activitiesCount: Int
    let hasActivities: Bool
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: UIConstants.MonthList.localeIdentifier)
        formatter.dateFormat = UIConstants.MonthList.monthFormat
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: UIConstants.MonthList.documentIcon)
                Text(monthYearString)
            }
            Spacer()
            Image(systemName: UIConstants.MonthList.monthNavigationIcon)
                .fontWeight(.medium)
                .font(.body)
        }
        .font(.body)
        .fontWeight(.semibold)
        .foregroundColor(UIConstants.MonthList.monthCardText)
        .padding()
        .background(UIConstants.MonthList.monthCardBackground)
        .cornerRadius(UIConstants.MonthList.monthCardCornerRadius)
    }
}
