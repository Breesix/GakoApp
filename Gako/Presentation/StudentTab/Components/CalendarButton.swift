//
//  CalendarButton.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//
//  Description: A button component that shows a calendar date picker in a sheet
//  Usage: Use this component to allow date selection through a calendar interface
//

import SwiftUI

struct CalendarButton: View {
    // MARK: - Constants
    private let buttonBackground = UIConstants.CalendarButton.buttonBackground
    private let iconColor = UIConstants.CalendarButton.iconColor
    private let buttonSize = UIConstants.CalendarButton.buttonSize
    private let iconSize = UIConstants.CalendarButton.iconSize
    private let toolbarTopPadding = UIConstants.CalendarButton.toolbarTopPadding
    private let toolbarHorizontalPadding = UIConstants.CalendarButton.toolbarHorizontalPadding
    private let contentPadding = UIConstants.CalendarButton.contentPadding
    private let datePickerTitle = UIConstants.CalendarButton.datePickerTitle
    private let headerTitle = UIConstants.CalendarButton.headerTitle
    private let localeIdentifier = UIConstants.CalendarButton.localeIdentifier
    private let calendarIcon = UIConstants.CalendarButton.calendarIcon
    private let closeIcon = UIConstants.CalendarButton.closeIcon
    
    // MARK: - Properties
    @Binding var selectedDate: Date
    @Binding var isShowingCalendar: Bool
    var onDateSelected: (Date) -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: { isShowingCalendar = true }) {
            calendarButton
        }
        .sheet(isPresented: $isShowingCalendar) {
            calendarSheet
        }
    }
    
    // MARK: - Subview
    private var calendarButton: some View {
        ZStack {
            Circle()
                .frame(width: buttonSize)
                .foregroundStyle(buttonBackground)
            Image(systemName: calendarIcon)
                .font(.system(size: iconSize))
                .foregroundStyle(iconColor)
        }
    }
    
    // MARK: - Subview
    private var calendarSheet: some View {
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

// MARK: - Preview
#Preview {
    CalendarButton(
        selectedDate: .constant(Date()),
        isShowingCalendar: .constant(true),
        onDateSelected: { _ in print("Date selected")}
    )
}
