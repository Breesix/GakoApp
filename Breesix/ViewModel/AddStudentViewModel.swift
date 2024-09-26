//
//  AddChildVM.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

final class AddStudentViewModel: ObservableObject {
    
    @Published var nisn = ""
    @Published var name = ""
    @Published var gender = ""
    @Published var birthdate = Date()
    @Published var background = ""
    @Published var emergencyContact = ""
    @Published var autismLevel = ""
    @Published var likes = ""
    @Published var dislikes = ""
    @Published var skills = ""
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Function to add child with optional image
    func addStudent(image: UIImage?) async throws {
        guard let user = Auth.auth().currentUser else {
            print("No user found")
            return
        }
        
        //upload the image to Firebase Storage if provided
        var imageURL: String? = nil
        if let image = image {
            imageURL = try await uploadImage(image)
        }
        
        // Prepare the student data to be stored in Firestore
        let studentData: [String: Any] = [
            "nisn": nisn,
            "name": name,
            "gender": gender,
            "birthdate": Timestamp(date: birthdate),
            "background": background,
            "emergencyContact": emergencyContact,
            "autismLevel": autismLevel,
            "likes": likes,
            "dislikes": dislikes,
            "skills": skills,
            "teacherID": user.uid,
            "imageURL": imageURL ?? ""
        ]
        
        // Save the student data in Firestore under the current teacher's collection
        try await db.collection("teachers").document(user.uid).collection("student").document(nisn).setData(studentData)
    }
    
    private func uploadImage(_ image: UIImage) async throws -> String? {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
            
            let storageRef = Storage.storage().reference().child("student_images/\(UUID().uuidString).jpg")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            return try await withCheckedThrowingContinuation { continuation in
                storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                    guard error == nil else {
                        continuation.resume(throwing: error!)
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        if let downloadURL = url {
                            continuation.resume(returning: downloadURL.absoluteString)
                        } else {
                            continuation.resume(throwing: error!)
                        }
                    }
                }
            }
        }
}


