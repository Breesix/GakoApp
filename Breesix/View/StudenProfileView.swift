//
//  StudenProfileView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct StudentProfileView: View {
    let student: Student
    
    @StateObject private var viewModel = DailyActivityViewModel()
    
    var body: some View {
        VStack {
        
            // Check if imageUrl is available and display it
            if let imageUrl = student.imageUrl, !imageUrl.isEmpty {
                WebImage(url: URL(string: imageUrl))
                    .resizable()
                    .clipShape(Circle())
            } else {
                // Placeholder image when no imageUrl
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            
            Text("Name: \(student.name)")
                .font(.title)
            Text("Autism Level: \(student.autismLevel)")
                .font(.title2)
            
            // Display Daily Activities
            List(viewModel.dailyActivities) { activity in
                NavigationLink(destination: DailyActivityDetailView(dailyActivity: activity)) {
                    HStack {
                        Text(activity.date, style: .date)
                            .font(.headline)
                        Spacer()
                        Text(activity.summary)
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

