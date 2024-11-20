//
//  YearPickerView.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

import SwiftUI

struct YearPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    @State var selectedYear = 0
    
    // MARK: - Constants
    let years = Array(1900...2100)
    private let pickerWidth = UIConstants.MonthList.pickerWidth
    private let buttonPadding = UIConstants.MonthList.yearPickerButtonPadding
    private let buttonBackground = UIConstants.MonthList.yearPickerButtonBackground
    private let buttonTextColor = UIConstants.MonthList.yearPickerButtonText
    private let buttonCornerRadius = UIConstants.MonthList.yearPickerButtonCornerRadius
    private let contentPadding = UIConstants.MonthList.contentPadding.leading
    private let selectYearText = UIConstants.MonthList.selectYearText
    
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
