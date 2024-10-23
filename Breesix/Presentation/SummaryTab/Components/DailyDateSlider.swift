//
//  DailyDateSlider.swift
//  Breesix
//
//  Created by Rangga Biner on 23/10/24.
//

import SwiftUI

struct DailyDateSlider: View {
    @Binding var selectedDate: Date
    @State private var isShowingDatePicker = false
    
    var body: some View {
        HStack {
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20))
                    .foregroundStyle(.bgSecondary)
            }
            Spacer()
            Button {
                isShowingDatePicker = true
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text(formatDate(selectedDate))
                }
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.vertical, 7)
                .padding(.horizontal, 37)
                .background(.bgSecondary)
                .cornerRadius(32)
            }
            Spacer()
            .sheet(isPresented: $isShowingDatePicker) {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            
            Button {
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 20))
                    .foregroundStyle(.bgSecondary)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM ''yy"
        return formatter.string(from: date)
    }
}

#Preview {
    DailyDateSlider(selectedDate: .constant(Date.now))
}
