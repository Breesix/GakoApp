//
//  StudenProfileView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//

import SwiftUI

struct StudentProfileView: View {
    let student: Student
    
    @StateObject private var viewModel = DailyActivityViewModel()
    
    var body: some View {
        VStack {
            Text("Name: \(student.name)")
                .font(.title)
            Text("Birthdate: \(student.birthdate)")
                .font(.title2)
            
            // Display Daily Activities
            List(viewModel.dailyActivities) { activity in
                NavigationLink(destination: DailyActivityDetailView(dailyActivity: activity)) {
                    HStack {
                        Text(activity.date, style: .date) // Display date of the activity
                            .font(.headline)
                        Spacer()
                        Text(activity.summary) // Display a brief summary
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            // Add a button to log daily activity
            NavigationLink(destination: LogDailyActivityView(student: student)) {
                Text("Log Daily Activity")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle(student.name)
        .padding()
        .onAppear {
            // Set the studentID in the view model when the view appears
            viewModel.setStudentID(studentID: student.id)
            viewModel.fetchDailyActivities()
        }
    }
}


struct StudentProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockChild = Student(
            id: "123",
            nisn: "1221432423",
            name: "John Doe",
            gender: "Man",
            birthdate: Date(timeIntervalSince1970: 946684800), // Example: January 1, 2000
            background: "Student",
            emergencyContact: "08621312312312",
            autismLevel: "Intermediate",
            likes: "Sport",
            dislikes: "Vegetable",
            skills: "BasketBall",
            imageUrl: nil
        )

        StudentProfileView(student: mockChild)
    }
}

