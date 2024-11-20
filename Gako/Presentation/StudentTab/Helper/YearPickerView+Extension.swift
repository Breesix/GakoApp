//
//  YearPickerView+Extension.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides initialization and update methods for YearPickerView
//  Usage: Contains methods to initialize the selected year and update the selected date based on user input
//

import SwiftUI

extension YearPickerView {
    func initializeSelection() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: selectedDate)
        selectedYear = years.firstIndex(of: components.year ?? 2000) ?? 0
    }
    
    func updateSelectedDate() {
        var components = DateComponents()
        components.year = years[selectedYear]
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}
