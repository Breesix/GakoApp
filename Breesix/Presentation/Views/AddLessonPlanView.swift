//
//  AddLessonPlanView.swift
//  Breesix
//
//  Created by Akmal Hakim on 24/09/24.
//

//import SwiftUI
//import FirebaseFirestore
//
//struct AddLessonPlanView: View {
//    @ObservedObject var addViewModel = AddLessonPlanViewModel()
//
//    var viewModel: AgendaListViewModel
//    var weeklyTemplate: WeeklyTemplate? // Pass the WeeklyTemplate to which the lesson will be added
//
//    var body: some View {
//        VStack {
//            // Input fields for title and description
//            TextField("Title", text: $addViewModel.title)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            
//            TextField("Description", text: $addViewModel.description)
//                .padding()
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            
//            // Days selection
//            List {
//                ForEach(addViewModel.daysOfWeek, id: \.self) { day in
//                    Toggle(day, isOn: Binding(
//                        get: { addViewModel.selectedDays.contains(day) },
//                        set: { isSelected in
//                            if isSelected {
//                                addViewModel.selectedDays.append(day)
//                            } else {
//                                addViewModel.selectedDays.removeAll { $0 == day }
//                            }
//                        }
//                    ))
//                }
//            }
//
//            // Save button
//            Button(action: {
//                let newPlan = addViewModel.createLessonPlan()
//                viewModel.addLessonPlan(newPlan)
//                
//                // Add new lesson to the WeeklyTemplate and update Firestore
//                var updatedTemplate = weeklyTemplate
//                updatedTemplate.lessons.append(newPlan)
//                
//                addViewModel.saveWeeklyTemplateToFirebase(updatedTemplate)
//            }) {
//                Text("Save Lesson Plan")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            .padding()
//        }
//    }
//}

//
//  AddLessonPlanView.swift
//  Breesix
//
//  Created by Akmal Hakim on 24/09/24.
//

import SwiftUI

struct AddLessonPlanView: View {
    @ObservedObject var viewModel: AgendaListViewModel
    @StateObject var addViewModel = AddLessonPlanViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            TextField("Title", text: $addViewModel.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Description", text: $addViewModel.description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Days selection
            List {
                ForEach(addViewModel.daysOfWeek, id: \.self) { day in
                    Toggle(day, isOn: Binding(
                        get: { addViewModel.selectedDays.contains(day) },
                        set: { isSelected in
                            if isSelected {
                                addViewModel.selectedDays.append(day)
                            } else {
                                addViewModel.selectedDays.removeAll { $0 == day }
                            }
                        }
                    ))
                }
            }
            
            Button(action: {
                if addViewModel.title.isEmpty {
                    alertMessage = "Please enter a title for the lesson plan."
                    showAlert = true
                } else if addViewModel.selectedDays.isEmpty {
                    alertMessage = "Please select at least one day for the lesson plan."
                    showAlert = true
                } else {
                    let newLessonPlan = addViewModel.createLessonPlan()
                    viewModel.addLessonPlan(newLessonPlan)
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Save Lesson Plan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            if !addViewModel.alphaNumCode.isEmpty {
                Text("Share Code: \(addViewModel.alphaNumCode)")
                    .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

//import SwiftUI
//
//struct AddLessonPlanView: View {
//    @ObservedObject var viewModel: AgendaListViewModel
//    @StateObject var addViewModel = AddLessonPlanViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showAlert = false
//    @State private var alertMessage = ""
//    
//    var body: some View {
//        VStack {
//            TextField("Title", text: $addViewModel.title)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//
//            TextField("Description", text: $addViewModel.description)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .padding()
//            
//            HStack {
//                Text("Days:")
//                ForEach(addViewModel.daysOfWeek, id: \.self) { day in
//                    Button(action: {
//                        if addViewModel.selectedDays.contains(day) {
//                            addViewModel.selectedDays.removeAll { $0 == day }
//                        } else {
//                            addViewModel.selectedDays.append(day)
//                        }
//                    }) {
//                        Text(day)
//                            .padding()
//                            .background(addViewModel.selectedDays.contains(day) ? Color.blue : Color.gray)
//                            .cornerRadius(5)
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//            .padding()
//            
//            Button(action: {
//                if addViewModel.title.isEmpty {
//                    alertMessage = "Please enter a title for the lesson plan."
//                    showAlert = true
//                } else if addViewModel.selectedDays.isEmpty {
//                    alertMessage = "Please select at least one day for the lesson plan."
//                    showAlert = true
//                } else {
//                    addViewModel.createWeeklyTemplate { success in
//                        if success {
//                            viewModel.addLessonPlan(addViewModel.weeklyTemplate!)
//                            presentationMode.wrappedValue.dismiss()
//                        } else {
//                            alertMessage = "Failed to create and save the WeeklyTemplate"
//                            showAlert = true
//                        }
//                    }
//                }
//            }) {
//                Text("Save Lesson Plan")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            .padding()
//            
//            if !addViewModel.alphaNumCode.isEmpty {
//                Text("Share Code: \(addViewModel.alphaNumCode)")
//                    .padding()
//            }
//        }
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
//        }
//    }
//}



//#Preview {
//    AddLessonPlanView()
//}
