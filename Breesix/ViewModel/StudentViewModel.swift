//
//  StudentViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//


import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

class StudentViewModel: ObservableObject {
    @Published var student: [Student] = [] // Changed variable name for clarity
    
    func fetchStudents() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("teachers")
            .document(userID)
            .collection("student")
            .getDocuments(source: .default) { (snapshot, error) in // Use explicit source parameter
                if let error = error {
                    print("Error fetching students: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Map the documents to the Student model
                self.student = documents.map { doc in
                    let birthdate: Date
                    if let timestamp = doc["birthdate"] as? Timestamp {
                        birthdate = timestamp.dateValue()
                    } else {
                        birthdate = Date() // Default value if conversion fails
                    }
                    
                    return Student(
                        id: doc.documentID,
                        nisn: doc["nisn"] as? String ?? "",
                        name: doc["name"] as? String ?? "",
                        gender: doc["gender"] as? String ?? "",
                        birthdate: birthdate,
                        background: doc["background"] as? String ?? "",
                        emergencyContact: doc["emergencyContact"] as? String ?? "",
                        autismLevel: doc["autismLevel"] as? String ?? "",
                        likes: doc["likes"] as? String ?? "",
                        dislikes: doc["dislikes"] as? String ?? "",
                        skills: doc["skills"] as? String ?? "",
                        imageUrl: doc["imageUrl"] as? String
                    )
                }
            }
    }
}

