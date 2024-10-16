//
//  DatePickerView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 11/10/24.
//


import SwiftUI

struct DatePickerView: View {
    @Binding var selectedDate: Date

    var body: some View {
        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
            .datePickerStyle(CompactDatePickerStyle())
            .labelsHidden()
    }
}
