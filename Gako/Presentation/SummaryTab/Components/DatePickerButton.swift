//
//  DatePicker.swift
//  Gako
//
//  Created by Rangga Biner on 13/11/24.
//
//  Description: A button to show a date and trigger a date picker sheet. 
//  Usage: Use this view to select a date in the summary tab.   

import SwiftUI

struct DatePickerButton: View {
    @Binding var isShowingDatePicker: Bool
    @Binding var selectedDate: Date
    @State private var tempDate: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }()
    
    init(
        isShowingDatePicker: Binding<Bool>,
        selectedDate: Binding<Date>
    ) {
        self._isShowingDatePicker = isShowingDatePicker
        self._selectedDate = selectedDate
        let validDate = DateValidator.isValidDate(selectedDate.wrappedValue) ? selectedDate.wrappedValue : DateValidator.maximumDate()
        self._tempDate = State(initialValue: validDate)
    }
    
    var body: some View {
        Button(action: {
            isShowingDatePicker = true
        }) {
            HStack {
                Image(systemName: "calendar")
                Text(dateFormatter.string(from: selectedDate))
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.buttonPrimaryLabel)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(.buttonOncard)
            .cornerRadius(8)
        }
        .sheet(isPresented: $isShowingDatePicker) {
            datePickerSheet()
        }
    }
    
    private func datePickerSheet() -> some View {
        NavigationStack {
            DatePicker(
                "Select Date",
                selection: $tempDate,
                in: ...DateValidator.maximumDate(),
                displayedComponents: .date
            )
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
                        isShowingDatePicker = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding(.top, 14)
                    .padding(.horizontal, 12)
                }
            }
            .onChange(of: tempDate) {
                if DateValidator.isValidDate(tempDate) {
                    selectedDate = tempDate
                    isShowingDatePicker = false
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    DatePickerButton(
        isShowingDatePicker: .constant(false),
        selectedDate: .constant(.now)
    )
}
