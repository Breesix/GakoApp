//
//  CalendarButton.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct CalendarButton: View {
    // MARK: - Constants
    private let buttonBackground = UIConstants.Calendar.buttonBackground
    private let iconColor = UIConstants.Calendar.iconColor
    private let buttonSize = UIConstants.Calendar.buttonSize
    private let iconSize = UIConstants.Calendar.iconSize
    private let toolbarTopPadding = UIConstants.Calendar.toolbarTopPadding
    private let toolbarHorizontalPadding = UIConstants.Calendar.toolbarHorizontalPadding
    private let contentPadding = UIConstants.Calendar.contentPadding
    
    private let datePickerTitle = UIConstants.Calendar.datePickerTitle
    private let headerTitle = UIConstants.Calendar.headerTitle
    private let localeIdentifier = UIConstants.Calendar.localeIdentifier
    private let calendarIcon = UIConstants.Calendar.calendarIcon
    private let closeIcon = UIConstants.Calendar.closeIcon
    
    // MARK: - Properties
    @Binding var selectedDate: Date
    @Binding var isShowingCalendar: Bool
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        Button(action: { isShowingCalendar = true }) {
            ZStack {
                Circle()
                    .frame(width: buttonSize)
                    .foregroundStyle(buttonBackground)
                Image(systemName: calendarIcon)
                    .font(.system(size: iconSize))
                    .foregroundStyle(iconColor)
            }
        }
        .sheet(isPresented: $isShowingCalendar) {
            NavigationStack {
                DatePicker(datePickerTitle,
                          selection: $selectedDate,
                          in: ...DateValidator.maximumDate(),
                          displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: localeIdentifier))
                    .padding(.horizontal, contentPadding)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Text(headerTitle)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .padding(.top, toolbarTopPadding)
                                .padding(.horizontal, toolbarHorizontalPadding)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isShowingCalendar = false
                            } label: {
                                Image(systemName: closeIcon)
                            }
                            .padding(.top, toolbarTopPadding)
                            .padding(.horizontal, toolbarHorizontalPadding)
                        }
                    }
                    .onChange(of: selectedDate) {
                        onDateSelected(selectedDate)
                        isShowingCalendar = false
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
