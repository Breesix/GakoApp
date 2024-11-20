//
//  MonthCard+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides date formatting for MonthCard
//  Usage: Contains method for formatting month and year display
//

import Foundation

extension MonthCard {
     var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: UIConstants.MonthList.localeIdentifier)
        formatter.dateFormat = UIConstants.MonthList.monthFormat
        return formatter.string(from: date)
    }
}
