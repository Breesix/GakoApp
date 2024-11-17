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

    @State private var selectedYear: Date = Date()
    @State private var isShowingYearPicker = false
    
    @State private var isEditing = false
    
    @State private var newStudentImage: UIImage?
    
    private var formattedYear: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "yyyy"
        return formatter.string(from: selectedYear)
    }
    
    var body: some View {
        ZStack {
            Color.bgMain.ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                                    .fontWeight(.semibold)
                                Text("Murid")
                                    .foregroundStyle(.white)
                                    .font(.body)
                                    .fontWeight(.regular)
                            }
                        }
                        Spacer()
                        Button(action: {
                            isEditing = true
                        }) {
                            Text("Edit Profil")
                                .foregroundStyle(.white)
                                .font(.body)
                                .fontWeight(.regular)
                        }
                    }
                    .padding(14)
                }
                .frame(height: 58)
                
                VStack (spacing: 12) {
                ProfileHeader(student: student)
                        .padding(.horizontal, 16)
                
                Divider()
                        .padding(.bottom, 12)
                
                    HStack (spacing: 16) {
                    Text("Lihat Dokumentasi")
                        .fontWeight(.semibold)
                        .foregroundColor(.labelPrimaryBlack)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: { moveYear(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(.buttonLinkOnSheet)
                        }
                        Button(action: { moveYear(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(isNextYearDisabled ? .gray : .buttonLinkOnSheet)
                        }
                        .disabled(isNextYearDisabled)
                        
                    }
                    
                    Button(action: { isShowingYearPicker.toggle() }) {
                        Text(formattedYear)
                            .font(.headline)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 14)
                    .background(Color.buttonLinkOnSheet)
                    .foregroundStyle(.buttonPrimaryLabel)
                    .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 0)
                
                // Month List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(getAllMonthsForYear(), id: \.self) { date in
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
                                MonthCard(
                                    date: date,
                                    activitiesCount: getActivityCount(for: date),
                                    hasActivities: hasActivities(for: date)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
                .padding(.top, 12)
        }
        }
        .toolbar(.hidden, for: .bottomBar,.tabBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .hideTabBar()
        .task {
            await fetchData()
        }
        .sheet(isPresented: $isShowingYearPicker) {
            YearPickerView(selectedDate: $selectedYear)
                .presentationDetents([.fraction(0.3)])
        }
        .sheet(isPresented: $isEditing) {
            ManageStudentView(
                mode: .edit(student),
                compressedImageData: compressedImageData,
                newStudentImage: newStudentImage,
                onSave: onAddStudent,
                onUpdate: onUpdateStudent,
                onImageChange: { image in
                    newStudentImage = image
                },
                checkNickname: onCheckNickname
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
    }
    
    private var isNextYearDisabled: Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let selectedYear = calendar.component(.year, from: selectedYear)
        
        return (selectedYear >= currentYear)
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

    private func moveYear(by value: Int) {
        if let newDate = calendar.date(byAdding: .year, value: value, to: selectedYear) {
            selectedYear = newDate
        }
    }
    
    private func getAllMonthsForYear() -> [Date] {
        let year = calendar.component(.year, from: selectedYear)
        let currentDate = Date()
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        
        // Jika tahun yang dipilih adalah tahun saat ini
        if year == currentYear {
            // Hanya tampilkan bulan dari Januari sampai bulan saat ini
            return (1...currentMonth).compactMap { month in
                calendar.date(from: DateComponents(year: year, month: month))
            }
        }
        // Jika tahun yang dipilih adalah tahun sebelumnya
        else if year < currentYear {
            // Tampilkan semua bulan (1-12)
            return (1...12).compactMap { month in
                calendar.date(from: DateComponents(year: year, month: month))
            }
        }
        // Jika tahun yang dipilih adalah tahun yang akan datang
        else {
            // Tidak menampilkan bulan apapun
            return []
        }
    }
    
    private func hasActivities(for date: Date) -> Bool {
        getActivityCount(for: date) > 0
    }
}

struct MonthCard: View {
    let date: Date
    let activitiesCount: Int
    let hasActivities: Bool
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "document.fill")
                Text(monthYearString)
//                Text(hasActivities ? "\(activitiesCount) aktivitas" : "Tidak ada aktivitas")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .fontWeight(.medium)
                .font(.body)
        }
        .font(.body)
        .fontWeight(.semibold)
        .foregroundColor(.labelPrimaryBlack)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct YearPickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMonth = 0
    @State private var selectedYear = 0
    
    let months = Calendar.current.monthSymbols
    let years = Array(1900...2100)
    
    var body: some View {
        VStack {
            HStack {
                Picker("Year", selection: $selectedYear) {
                    ForEach(0..<years.count, id: \.self) { index in
                        Text(String(years[index])).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100)
            }
            .padding()
            
            Button("Pilih Tahun") {
                updateSelectedDate()
                presentationMode.wrappedValue.dismiss()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .background(Color.buttonLinkOnSheet)
            .foregroundStyle(.buttonPrimaryLabel)
            .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .presentationDetents([.fraction(0.4)])
        .onAppear {
            initializeSelection()
        }
    }
    
    private func initializeSelection() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .year], from: selectedDate)
        selectedMonth = (components.month ?? 1) - 1
        selectedYear = years.firstIndex(of: components.year ?? 2000) ?? 0
    }
    
    private func updateSelectedDate() {
        var components = DateComponents()
        components.month = selectedMonth + 1
        components.year = years[selectedYear]
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}
