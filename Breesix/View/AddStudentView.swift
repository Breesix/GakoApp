//
//  AddStudentView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//

import SwiftUI
import PhotosUI

struct AddStudentView: View {
    
    @StateObject private var viewModel = AddStudentViewModel()
    @State private var selectedImage: UIImage? = nil // State for holding the selected image
    @State private var isImagePickerPresented = false // State to present image picker
    @State private var errorMessage: String = "" // For displaying error messages
    
    var body: some View {
        
        // Image Picker
        Button(action: {
            isImagePickerPresented = true
        }) {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Text("Select Image")
                    .font(.headline)
                    .padding()
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage)
        }
    
        Form {
            Section(header: Text("Student Information")) {
                TextField("NISN", text: $viewModel.nisn)
                TextField("Name", text: $viewModel.name)
                TextField("Gender", text: $viewModel.gender)
                DatePicker("Birthdate", selection: $viewModel.birthdate, displayedComponents: .date)
                TextField("Background", text: $viewModel.background)
                TextField("Emergency Contact", text: $viewModel.emergencyContact)
                TextField("Autism Level", text: $viewModel.autismLevel)
                TextField("Likes", text: $viewModel.likes)
                TextField("Dislikes", text: $viewModel.dislikes)
                TextField("Skills", text: $viewModel.skills)
            }
            

            Button(action: {
                Task {
                    do {
                        // Call viewModel.addStudent and pass the selected image
                        try await viewModel.addStudent(image: selectedImage)
                        print("Student added successfully!")
                    } catch {
                        errorMessage = "Error adding student: \(error.localizedDescription)"
                    }
                }
            }) {
                Text("Add Student")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
            
            // Display error messages if any
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        .navigationTitle("Add Student")
        .padding()
        .sheet(isPresented: $isImagePickerPresented) {
            // Present the image picker when the button is tapped
            ImagePicker(selectedImage: $selectedImage)
        }
    }
}

#Preview {
    AddStudentView()
}

