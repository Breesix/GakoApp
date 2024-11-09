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
            NavigationStack {
                DatePicker("Tanggal", selection: $selectedDate, in: ...DateValidator.maximumDate(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "id_ID"))
                    .padding(.horizontal, 16)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text("Pilih Tanggal")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.top, 14)
                                .padding(.horizontal, 12)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isShowingCalendar = false
                            } label: {
                                Image(systemName: "xmark")
                            }
                            .padding(.top, 14)
                            .padding(.horizontal, 12)
                        }
                    }
                    .onChange(of: selectedDate) {
                        onDateSelected(selectedDate)
                    }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)

        }
    }
}

#Preview {
    CalendarButton(
        selectedDate: .constant(Date()),
        isShowingCalendar: .constant(true),
        onDateSelected: { _ in print("Date selected")}
    )
}
