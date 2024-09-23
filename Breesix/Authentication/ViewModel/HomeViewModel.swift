////
////  HomeViewModel.swift
////  Breesix
////
////  Created by Kevin Fairuz on 22/09/24.
////
//
//import Foundation
//import Firebase
//import FirebaseAuth
//import SwiftUI
//

//
//
//final class HomeViewModel: ObservableObject {
//    @Published var student = [Student]()
//    
//    func fetchChildren() {
//        guard let teacherID = Auth.auth().currentUser?.uid else {
//            print("User not logged in")
//            return
//        }
//        
//        Firestore.firestore().collection("teachers").document(teacherID).collection("student").getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error fetching student: \(error)")
//                return
//            }
//            
//            guard let documents = snapshot?.documents else { return }
//            
//            self.student = documents.map { doc in
//                let data = doc.data()
//                let id = doc.documentID
//                let name = data["name"] as? String ?? ""
//                let birthdate = data["birthdate"] as? String ?? ""
//                return Student(id: id, name: name, birthdate: birthdate)
//            }
//        }
//    }
//}
