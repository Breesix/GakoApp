//
//  MonthListViewModel.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: ViewModel for managing monthly activities and notes for a student
//  Usage: Use this class to fetch, manage, and update the activities and notes associated with a selected year
//

import Foundation
import UIKit

@MainActor
final class MonthListViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var activities: [Activity] = []
    @Published private(set) var notes: [Note] = []
    @Published var selectedYear: Date = Date()
    @Published var isShowingYearPicker = false
    @Published var isEditing = false
    @Published var newStudentImage: UIImage?
    
    // MARK: - Private Properties
    private let calendar = Calendar.current
    private let student: Student
    private let onFetchActivities: (Student) async -> [Activity]
    private let onFetchNotes: (Student) async -> [Note]
    
    // MARK: - Computed Properties
    var formattedYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: UIConstants.MonthListView.localeIdentifier)
        formatter.dateFormat = UIConstants.MonthListView.yearFormat
        return formatter.string(from: selectedYear)
    }
    
    var isNextYearDisabled: Bool {
        let currentYear = calendar.component(.year, from: Date())
        let selectedYear = calendar.component(.year, from: self.selectedYear)
        return selectedYear >= currentYear
    }
    
    // MARK: - Initialization
    init(student: Student,
         onFetchActivities: @escaping (Student) async -> [Activity],
         onFetchNotes: @escaping (Student) async -> [Note]) {
        self.student = student
        self.onFetchActivities = onFetchActivities
        self.onFetchNotes = onFetchNotes
    }
    
    // MARK: - Public Methods
    func fetchData() async {
        async let fetchedActivities = onFetchActivities(student)
        async let fetchedNotes = onFetchNotes(student)
        
        let (activities, notes) = await (fetchedActivities, fetchedNotes)
        
        self.activities = activities
        self.notes = notes
    }
    
    func moveYear(by value: Int) {
        guard let newDate = calendar.date(byAdding: .year, value: value, to: selectedYear) else { return }
        selectedYear = newDate
    }
    
    func getAllMonthsForYear() -> [Date] {
        let year = calendar.component(.year, from: selectedYear)
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        if year == currentYear {
            return (1...currentMonth).compactMap { month in
                calendar.date(from: DateComponents(year: year, month: month))
            }
        } else if year < currentYear {
            return (1...12).compactMap { month in
                calendar.date(from: DateComponents(year: year, month: month))
            }
        }
        return []
    }
    
    func getActivityCount(for date: Date) -> Int {
        let activitiesInMonth = activities.filter {
            calendar.isDate($0.createdAt, equalTo: date, toGranularity: .month)
        }.count
        
        let notesInMonth = notes.filter {
            calendar.isDate($0.createdAt, equalTo: date, toGranularity: .month)
        }.count
        
        return activitiesInMonth + notesInMonth
    }
    
    func hasActivities(for date: Date) -> Bool {
        getActivityCount(for: date) > 0
    }
    
    func handleImageChange(_ image: UIImage?) {
        newStudentImage = image
    }
    
    func toggleYearPicker() {
        isShowingYearPicker.toggle()
    }
    
    func toggleEditing() {
        isEditing.toggle()
    }
}
