//
//  YearPickerView.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct YearPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedYear = 0
    
    private let years = Array(1900...2100)
    
    var body: some View {
        VStack {
            Picker("Year", selection: $selectedYear) {
                ForEach(0..<years.count, id: \.self) { index in
                    Text(String(years[index])).tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 100)
            .padding()
            
            Button(UIConstants.MonthList.selectYearText) {
                updateSelectedDate()
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(UIConstants.MonthList.yearPickerButtonPadding)
            .background(UIConstants.MonthList.yearPickerButtonBackground)
            .foregroundStyle(UIConstants.MonthList.yearPickerButtonText)
            .cornerRadius(UIConstants.MonthList.yearPickerButtonCornerRadius)
        }
        .padding(.horizontal, UIConstants.MonthList.contentPadding.leading)
        .onAppear {
            initializeSelection()
        }
    }
    
    private func initializeSelection() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: selectedDate)
        selectedYear = years.firstIndex(of: components.year ?? 2000) ?? 0
    }
    
    private func updateSelectedDate() {
        var components = DateComponents()
        components.year = years[selectedYear]
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}
