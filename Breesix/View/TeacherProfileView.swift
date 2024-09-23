//
//  TeacherProfileView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TeacherProfileView: View {
    
    @State private var teacherID = ""
    @State private var teacherName = ""
    @State private var errorMessage = ""
    @State private var showSettingsView = false
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            // Display basic teacher profile information
            if !teacherName.isEmpty {
                Text("Teacher Name: \(teacherName)")
                    .font(.headline)
                    .padding(.bottom, 10)
            }
            
            Text("Teacher ID: \(teacherID)")
                .font(.subheadline)
                .padding(.bottom, 20)
            
            Spacer()

            // Button to navigate to Settings View
            Button(action: {
                showSettingsView = true
            }) {
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            
            NavigationLink("", destination: SettingsView(showSignInView: $showSignInView), isActive: $showSettingsView)
        }
        .padding()
        .onAppear {
            fetchTeacherProfile()
        }
    }
    
    func fetchTeacherProfile() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        let db = Firestore.firestore()
        db.collection("teachers").document(userID).getDocument { document, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let document = document, document.exists {
                teacherName = document.data()?["name"] as? String ?? "Unknown"
                teacherID = userID
            } else {
                errorMessage = "Teacher profile not found"
            }
        }
    }
}



func saveTeacherProfile(name: String, contactInfo: String, completion: @escaping (Result<Void, Error>) -> Void) {
    guard let userID = Auth.auth().currentUser?.uid else {
        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
        return
    }
    
    let teacherData: [String: Any] = [
        "name": name,
        "contactInfo": contactInfo
    ]
    
    Firestore.firestore().collection("teachers").document(userID).setData(teacherData) { error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}

#Preview {
    TeacherProfileView(showSignInView: .constant(false))
}
