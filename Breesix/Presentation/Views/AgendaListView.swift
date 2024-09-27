////
////  AgendaListView.swift
////  Breesix
////
////  Created by Akmal Hakim on 24/09/24.
////
//
//import SwiftUI
//
//struct AgendaListView: View {
//    @ObservedObject var viewModel = AgendaListViewModel()
//    @State private var selectedView = 0 // 0 for Activity List, 1 for Weekly View
//    @State private var selectedDate = Date() // Holds the currently selected date
//    @State private var showingAddActivity = false // State to control the sheet presentation
//    
//    var body: some View {
//        VStack {
//            // Picker to toggle between Activity List and Weekly View
//            Picker(selection: $selectedView, label: Text("View Mode")) {
//                Text("Activity List").tag(0)
//                Text("Weekly View").tag(1)
//            }
//            .pickerStyle(.segmented)
//            .padding()
//            
//            if selectedView == 0 {
//                // Activity List View
//                List(viewModel.lessonPlans, id: \.id) { lessonPlan in
//                    VStack {
//                        Text(lessonPlan.title)
//                        Text(lessonPlan.days.joined(separator: ", "))
//                            .font(.subheadline)
//                    }
//                }
//            } else {
//                // Weekly View
//                WeeklyView(selectedDate: $selectedDate, viewModel: viewModel)
//            }
//            
//            Spacer()
//            
//            // Button to add a new activity
//            Button(action: {
//                showingAddActivity.toggle() // Trigger the sheet
//            }) {
//                Text("Add Activity")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//            .padding()
//            .sheet(isPresented: $showingAddActivity) {
//                AddLessonPlanView(viewModel: viewModel)
//            }
//        }
//    }
//}
//
//
//struct WeeklyView: View {
//    @Binding var selectedDate: Date
//    @ObservedObject var viewModel: AgendaListViewModel
//    
//    var body: some View {
//        VStack {
//            WeeklyDatePicker(selectedDate: $selectedDate)
//            .padding()
//            
//            // Display activities for the selected date
//            Text("Activities for \(formattedDay(selectedDate))")
//                .font(.headline)
//                .padding(.top)
//            
//            List(viewModel.filterLessonPlans(for: formattedDay(selectedDate), from: viewModel.lessonPlans), id: \.id) { activity in
//                Text(activity.title)
//            }
//        }
//    }
//    
//    // Helper function to format the date
//    func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        return formatter.string(from: date)
//    }
//    
//    func formattedDay(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEE"
//        return formatter.string(from: date)
//    }
//}
//
//struct WeeklyDatePicker: View {
//    @Binding var selectedDate: Date
//    
//    var body: some View {
//        VStack {
//            // Header for the selected week
//            
//            // Get the current week's start date (Monday)
//            let calendar = Calendar.current
//            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
//
//            // Create a row of buttons for each day of the week
//            HStack {
//                ForEach(0..<7) { index in
//                    let date = calendar.date(byAdding: .day, value: index, to: startOfWeek)!
//                    Button(action: {
//                        selectedDate = date
//                    }) {
//                        Text(formattedDay(calendar.date(byAdding: .day, value: index, to: startOfWeek)!))
//                            .font(.footnote)
//                            .padding()
//                            .background(selectedDate.isSameDay(as: date) ? Color.blue : Color.clear)
//                            .foregroundColor(selectedDate.isSameDay(as: date) ? Color.white : Color.black)
//                            .cornerRadius(5)
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//    
//    func formattedDay(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "EEEEE"
//        return formatter.string(from: date)
//    }
//}
//
//extension Date {
//    func isSameDay(as date: Date) -> Bool {
//        let calendar = Calendar.current
//        return calendar.isDate(self, inSameDayAs: date)
//    }
//}

//
//  AgendaListView.swift
//  Breesix
//
//  Created by Akmal Hakim on 24/09/24.
//

import SwiftUI

struct AgendaListView: View {
    @ObservedObject var viewModel = AgendaListViewModel()
    @State private var selectedView = 0 // 0 for Activity List, 1 for Weekly View
    @State private var selectedDate = Date() // Holds the currently selected date
    @State private var showingAddActivity = false // State to control the sheet presentation
    @State private var showingCodeInput = false // State for showing the alphanumeric code input sheet
    @State private var alphaNumCodeInput = "" // Holds the alphanumeric code entered by the user
    
    var body: some View {
        VStack {
            // Picker to toggle between Activity List and Weekly View
            Picker(selection: $selectedView, label: Text("View Mode")) {
                Text("Activity List").tag(0)
                Text("Weekly View").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedView == 0 {
                // Activity List View
                List(viewModel.weeklyTemplate?.lessons ?? [], id: \.id) { lessonPlan in
                    VStack {
                        Text(lessonPlan.title)
                        Text(lessonPlan.days.joined(separator: ", "))
                            .font(.subheadline)
                    }
                }
            } else {
                // Weekly View
                WeeklyView(selectedDate: $selectedDate, viewModel: viewModel)
            }
            
            Spacer()
            
            // Button to add a new activity
            Button(action: {
                showingAddActivity.toggle() // Trigger the sheet
            }) {
                Text("Add Activity")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showingAddActivity) {
                AddLessonPlanView(viewModel: viewModel)
            }
            
            // Button to input alphanumeric code for WeeklyTemplate
            Button(action: {
                showingCodeInput.toggle() // Show the sheet for entering code
            }) {
                Text("Enter Alphanumeric Code")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
            .sheet(isPresented: $showingCodeInput) {
                CodeInputSheet(viewModel: viewModel, alphaNumCode: $alphaNumCodeInput)
            }
        }
    }
}

struct CodeInputSheet: View {
    @ObservedObject var viewModel: AgendaListViewModel
    @Binding var alphaNumCode: String
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            TextField("Enter Alphanumeric Code", text: $alphaNumCode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                viewModel.fetchWeeklyTemplateByCode(alphaNumCode) { success in
                    if success {
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        alertMessage = "Invalid code or error fetching template."
                        showAlert = true
                    }
                }
            }) {
                Text("Load Template")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

//struct CodeInputSheet: View {
//    @ObservedObject var viewModel: AgendaListViewModel
//    @Binding var alphaNumCode: String
//    
//    var body: some View {
//        VStack {
//            Text("Enter Alphanumeric Code")
//                .font(.headline)
//                .padding()
//            
//            TextField("Alphanumeric Code", text: $alphaNumCode)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            Button(action: {
//                // Fetch WeeklyTemplate based on inputted alphanumeric code
//                $viewModel.fetchWeeklyTemplateByCode(alphaNumCode) { template in
//                    if let template = template {
//                        print("Fetched template: \(template)")
//                    } else {
//                        print("Template not found.")
//                    }
//                }
//            }) {
//                Text("Submit Code")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//            .padding()
//            
//            Spacer()
//        }
//        .padding()
//    }
//}


struct WeeklyView: View {
    @Binding var selectedDate: Date
    @ObservedObject var viewModel: AgendaListViewModel
    
    var body: some View {
        VStack {
            WeeklyDatePicker(selectedDate: $selectedDate)
            .padding()
            
            Text("Activities for \(formattedDay(selectedDate))")
                .font(.headline)
                .padding(.top)
            
            List(viewModel.filterLessonPlans(for: formattedDay(selectedDate), from: viewModel.weeklyTemplate?.lessons ?? []), id: \.id) { activity in
                Text(activity.title)
            }
        }
    }
    
    func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

struct WeeklyDatePicker: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        VStack {
            let calendar = Calendar.current
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!

            HStack {
                ForEach(0..<7) { index in
                    let date = calendar.date(byAdding: .day, value: index, to: startOfWeek)!
                    Button(action: {
                        selectedDate = date
                    }) {
                        Text(formattedDay(calendar.date(byAdding: .day, value: index, to: startOfWeek)!))
                            .font(.footnote)
                            .padding()
                            .background(selectedDate.isSameDay(as: date) ? Color.blue : Color.clear)
                            .foregroundColor(selectedDate.isSameDay(as: date) ? Color.white : Color.black)
                            .cornerRadius(5)
                    }
                }
            }
            .padding()
        }
    }
    
    func formattedDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date)
    }
}

extension Date {
    func isSameDay(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: date)
    }
}


//#Preview {
//    AgendaListView()
//}
