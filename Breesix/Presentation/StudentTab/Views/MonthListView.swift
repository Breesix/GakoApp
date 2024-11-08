//
//  MonthListView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/11/24.
//

import SwiftUI

struct MonthListView: View {
    let student: Student
    let onAddStudent: (Student) async -> Void
    let onUpdateStudent: (Student) async -> Void
    let onAddNote: (Note, Student) async -> Void
    let onUpdateNote: (Note) async -> Void
    let onDeleteNote: (Note, Student) async -> Void
    let onAddActivity: (Activity, Student) async -> Void
    let onDeleteActivity: (Activity, Student) async -> Void
    let onUpdateActivityStatus: (Activity, Status) async -> Void
    let onFetchNotes: (Student) async -> [Note]
    let onFetchActivities: (Student) async -> [Activity]
    let onCheckNickname: (String, UUID?) -> Bool
    let compressedImageData: Data?
    
    @Environment(\.presentationMode) var presentationMode
    @State private var activities: [Activity] = []
    @State private var notes: [Note] = []
    
    private let calendar = Calendar.current
    
    // as a middle view
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                ZStack {
                    Color(.bgSecondary)
                        .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                        .ignoresSafeArea(edges: .top)
                    
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack(spacing: 3) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.white)
                                Text("Kembali")
                                    .foregroundStyle(.white)
                            }
                        }
                        Spacer()
                    }
                    .padding(14)
                }
                .frame(height: 58)
                
                // Profile Header
                ProfileHeader(student: student)
                    .padding(16)
                
                Divider()
                
                // Month List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(getAvailableMonths(), id: \.self) { date in
                            NavigationLink(destination: StudentDetailView(
                                student: student,
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
                                onCheckNickname: onCheckNickname,
                                compressedImageData: compressedImageData,
                                initialScrollDate: date
                            )) {
                                MonthCard(date: date, activitiesCount: getActivityCount(for: date))
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await fetchData()
        }
    }
    
    private func fetchData() async {
        activities = await onFetchActivities(student)
        notes = await onFetchNotes(student)
    }
    
    private func getAvailableMonths() -> [Date] {
        let allDates = activities.map { $0.createdAt } + notes.map { $0.createdAt }
        let monthComponents = Set(allDates.map { date in
            calendar.dateComponents([.year, .month], from: date)
        })
        
        return monthComponents.compactMap { components in
            calendar.date(from: components)
        }.sorted(by: >)
    }
    
    private func getActivityCount(for date: Date) -> Int {
        let activitiesInMonth = activities.filter {
            calendar.isDate($0.createdAt, equalTo: date, toGranularity: .month)
        }.count
        
        let notesInMonth = notes.filter {
            calendar.isDate($0.createdAt, equalTo: date, toGranularity: .month)
        }.count
        
        return activitiesInMonth + notesInMonth
    }
}

struct MonthCard: View {
    let date: Date
    let activitiesCount: Int
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(monthYearString)
                    .font(.headline)
                    .foregroundColor(.labelPrimaryBlack)
                Text("\(activitiesCount) aktivitas")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

