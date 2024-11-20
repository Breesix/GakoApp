//
//  YearPickerView.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A wheel picker component for selecting years
//  Usage: Use this view to allow year selection in a wheel picker format
//

import SwiftUI

struct YearPickerView: View {
    // MARK: - Constants
    let years = UIConstants.YearPickerView.years
    private let pickerWidth = UIConstants.YearPickerView.pickerWidth
    private let buttonPadding = UIConstants.YearPickerView.yearPickerButtonPadding
    private let buttonBackground = UIConstants.YearPickerView.yearPickerButtonBackground
    private let buttonTextColor = UIConstants.YearPickerView.yearPickerButtonText
    private let buttonCornerRadius = UIConstants.YearPickerView.yearPickerButtonCornerRadius
    private let contentPadding = UIConstants.YearPickerView.contentPadding.leading
    private let selectYearText = UIConstants.YearPickerView.selectYearText

    // MARK: - Properties
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    @State var selectedYear = 0
    
    // MARK: - Body
    var body: some View {
        VStack {
            Picker("Year", selection: $selectedYear) {
                ForEach(0..<years.count, id: \.self) { index in
                    Text(String(years[index])).tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: pickerWidth)
            .padding()
            
            Button(selectYearText) {
                updateSelectedDate()
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(buttonPadding)
            .background(buttonBackground)
            .foregroundStyle(buttonTextColor)
            .cornerRadius(buttonCornerRadius)
        }
        .padding(.horizontal, contentPadding)
        .onAppear {
            initializeSelection()
        }
    }
}

// MARK: - Preview
#Preview {
    YearPickerView(selectedDate: .constant(.now))
}
