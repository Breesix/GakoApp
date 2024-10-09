//
//  WeeklyDatePicker.swift
//  Breesix
//
//  Created by Akmal Hakim on 08/10/24.
//
import SwiftUI
import Foundation

struct WeeklyDatePickerView: View {
    @Binding var selectedDate: Date
    
    private let calendar = Calendar.current
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Button(action: { moveWeek(by: -1) }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.green)
            }
            
            ForEach(weekDates(), id: \.self) { date in
                VStack {
                    Text(dayFormatter.string(from: date).uppercased())
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    ZStack {
                        Circle()
                            .fill(calendar.isDate(selectedDate, inSameDayAs: date) ? Color.green.opacity(0.2) : Color.clear)
                            .frame(width: 32, height: 32)
                        
                        Text(dateFormatter.string(from: date))
                            .font(.subheadline)
                            .foregroundColor(calendar.isDate(selectedDate, inSameDayAs: date) ? .green : .primary)
                    }
                }
                .onTapGesture {
                    selectedDate = date
                }
            }
            
            Button(action: { moveWeek(by: 1) }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func weekDates() -> [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0...6).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    private func moveWeek(by value: Int) {
        if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
}
