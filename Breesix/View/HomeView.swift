//
//  HomeView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = StudentViewModel()
    @State private var showAddStudentView = false
    
    var body: some View {
        VStack {
            
            Button(action: {
                showAddStudentView = true
            }) {
                Text("Add Student")
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .padding(.top, 20)
            
            List(viewModel.student) { student in
                NavigationLink(destination: StudentProfileView(student: student)) {
                    HStack {
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
                        
                        VStack(alignment: .leading) {
                            Text(student.name)
                                .font(.headline)
                            Text("Birthdate: \(student.birthdate)")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .navigationTitle("My Students")
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.fetchStudents()
            }
            
            NavigationLink("", destination: AddStudentView(), isActive: $showAddStudentView)
        }
        .navigationTitle("Dokumentasi")
    }
}

#Preview {
    HomeView()
}

