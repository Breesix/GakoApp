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
    @State private var tempDate: Date
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }
    
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
                tempDate = selectedDate
                isShowingDatePicker = true
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text(formatDate(selectedDate))
                }
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.vertical, 6)
                .frame(width: 289)
                .background(.bgSecondary)
                .cornerRadius(32)
            }
            Spacer()
            .sheet(isPresented: $isShowingDatePicker) {
                DatePicker("Select Date", selection: $tempDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .onChange(of: tempDate) { newDate in
                        selectedDate = newDate
                        isShowingDatePicker = false
                    }
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
