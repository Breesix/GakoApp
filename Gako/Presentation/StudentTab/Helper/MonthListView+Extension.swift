//
//  MonthListView+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension that provides UI components and layout for MonthListView
//  Usage: Contains methods for creating header views, navigation buttons, and month list display
//

import SwiftUI

extension MonthListView {
    var headerView: some View {
        ZStack {
            UIConstants.MonthListView.headerBackgroundColor
                .cornerRadius(UIConstants.MonthListView.cornerRadius, corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea(edges: .top)
            
            HStack {
                backButton
                Spacer()
                editButton
            }
            .padding(UIConstants.MonthListView.headerPadding)
        }
        .frame(height: UIConstants.MonthListView.headerHeight)
    }
    
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack(spacing: 3) {
                Image(systemName: UIConstants.MonthListView.backIcon)
                    .foregroundColor(UIConstants.MonthListView.headerTextColor)
                    .fontWeight(.semibold)
                Text(UIConstants.MonthListView.backText)
                    .foregroundStyle(UIConstants.MonthListView.headerTextColor)
                    .font(.body)
                    .fontWeight(.regular)
            }
        }
    }
    
    var editButton: some View {
        Button(action: viewModel.toggleEditing) {
            Text(UIConstants.MonthListView.editProfileText)
                .foregroundStyle(UIConstants.MonthListView.headerTextColor)
                .font(.body)
                .fontWeight(.regular)
        }
    }
    
    var contentView: some View {
        VStack(spacing: UIConstants.MonthListView.spacing) {
            ProfileHeader(student: student)
                .padding(.horizontal, UIConstants.MonthListView.contentPadding.leading)
            
            Divider()
                .padding(.bottom, UIConstants.MonthListView.dividerPadding)
            
            documentationHeader
            monthList
        }
        .padding(.top, UIConstants.MonthListView.contentPadding.top)
    }
    
    var documentationHeader: some View {
        HStack(spacing: UIConstants.MonthListView.monthNavigationSpacing) {
            Text(UIConstants.MonthListView.documentationText)
                .fontWeight(.semibold)
                .foregroundColor(UIConstants.MonthListView.documentationTextColor)
            
            Spacer()
            
            yearNavigationButtons
            yearPickerButton
        }
        .padding(.horizontal, UIConstants.MonthListView.contentPadding.leading)
    }
    
    var yearNavigationButtons: some View {
        HStack(spacing: UIConstants.MonthListView.monthNavigationSpacing) {
            Button(action: { viewModel.moveYear(by: -1) }) {
                Image(systemName: UIConstants.MonthListView.backIcon)
                    .foregroundStyle(UIConstants.MonthListView.monthNavigationColor)
            }
            
            Button(action: { viewModel.moveYear(by: 1) }) {
                Image(systemName: UIConstants.MonthListView.nextIcon)
                    .foregroundStyle(viewModel.isNextYearDisabled ?
                        UIConstants.MonthListView.monthNavigationDisabledColor :
                        UIConstants.MonthListView.monthNavigationColor)
            }
            .disabled(viewModel.isNextYearDisabled)
        }
    }
    
    var yearPickerButton: some View {
        Button(action: viewModel.toggleYearPicker) {
            Text(viewModel.formattedYear)
                .font(.headline)
        }
        .padding(UIConstants.MonthListView.yearPickerButtonPadding)
        .background(UIConstants.MonthListView.yearPickerButtonBackground)
        .foregroundStyle(UIConstants.MonthListView.yearPickerButtonText)
        .cornerRadius(UIConstants.MonthListView.yearPickerButtonCornerRadius)
    }
    
    var monthList: some View {
        ScrollView {
            LazyVStack(spacing: UIConstants.MonthListView.spacing) {
                ForEach(viewModel.getAllMonthsForYear(), id: \.self) { date in
                    NavigationLink(destination: makeStudentDetailView(for: date)) {
                        MonthCard(
                            date: date,
                            activitiesCount: viewModel.getActivityCount(for: date),
                            hasActivities: viewModel.hasActivities(for: date)
                        )
                    }
                }
            }
            .padding(.horizontal, UIConstants.MonthListView.contentPadding.leading)
        }
    }
    
    func makeStudentDetailView(for date: Date) -> some View {
        StudentDetailView(
            student: student,
            initialScrollDate: date,
            compressedImageData: compressedImageData,
            onAddStudent: onAddStudent,
            onUpdateStudent: onUpdateStudent,
            onAddNote: onAddNote,
            onUpdateNote: onUpdateNote,
            onDeleteNote: onDeleteNote,
            onAddActivity: onAddActivity,
            onDeleteActivity: onDeleteActivity,
            onUpdateActivityStatus: onUpdateActivityStatus,
            onFetchNotes: onFetchNotes,
            onFetchActivities: onFetchActivities,
            onCheckNickname: onCheckNickname
        )
    }
}
