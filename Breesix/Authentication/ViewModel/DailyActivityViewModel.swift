//
//  DailyActivityViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import Foundation
import FirebaseFirestore

class DailyActivityViewModel: ObservableObject {
    @Published var dailyActivities: [DailyActivity] = []
    
    @Published var studentID: String?
    
    func setStudentID(studentID: String) {
        self.studentID = studentID
    }
    
    func fetchDailyActivities() {
        Firestore.firestore()
            .collection("students")
            .document(studentID ?? "")
            .collection("dailyActivities")
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching daily activities: \(error)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                self.dailyActivities = documents.map { doc in
                    DailyActivity(
                        id: doc.documentID,
                        date: (doc["date"] as? Timestamp)?.dateValue() ?? Date(),
                        summary: doc["summary"] as? String ?? "",
                        fullLog: doc["fullLog"] as? String ?? ""
                    )
                }
            }
    }
}
