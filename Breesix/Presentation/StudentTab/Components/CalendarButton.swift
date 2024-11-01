//
//  CalendarButton.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct CalendarButton: View {
    @Binding var selectedDate: Date
    @Binding var isShowingCalendar: Bool
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        
        Button(action: { isShowingCalendar = true }) {
            ZStack {
                Circle()
                    .frame(width: 36)
                    .foregroundStyle(.buttonLinkOnSheet)
                Image(systemName: "calendar")
                    .font(.system(size: 21))
                    .foregroundStyle(.white)
            }
        }
        
        .sheet(isPresented: $isShowingCalendar) {
            DatePicker("Tanggal", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .environment(\.locale, Locale(identifier: "id_ID"))
                .presentationDetents([.fraction(0.55)])
                .onChange(of: selectedDate) {
                    onDateSelected(selectedDate)
                }
        }
    }
}
