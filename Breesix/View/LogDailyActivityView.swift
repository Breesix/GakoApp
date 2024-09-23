//
//  LogDailyActivityView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/09/24.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LogDailyActivityView: View {
    @State private var activityText: String = ""
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode
    let student: Student
    
    var body: some View {
        VStack {
            Text("Log Daily Activity for \(student.name)")
                .font(.headline)
                .padding(.bottom, 20)
            
            TextEditor(text: $activityText)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()
                .disabled(isSubmitting)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom, 10)
            }
            
            Button(action: submitActivity) {
                if isSubmitting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Submit Activity")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .disabled(isSubmitting || activityText.isEmpty)
            .padding()
        }
        .padding()
        .navigationTitle("Log Activity")
    }
    
    // This method now uses the extracted logic to log activity
    func submitActivity() {
        guard let teacherID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            return
        }
        
        isSubmitting = true
        errorMessage = nil
        
        logActivity(studentID: student.id, summary: createSummary(from: activityText), fullLog: activityText) { success, error in
            isSubmitting = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else if success {
                presentationMode.wrappedValue.dismiss() // Dismiss on success
            }
        }
    }
    
    // Create a brief summary for the log (you can customize this logic)
    func createSummary(from fullText: String) -> String {
        return String(fullText.prefix(50)) + (fullText.count > 50 ? "..." : "")
    }
}

// Helper function to log activity, extracted for reuse
func logActivity(studentID: String, summary: String, fullLog: String, completion: @escaping (Bool, Error?) -> Void) {
    let db = Firestore.firestore()
    let newActivityRef = db.collection("students").document(studentID).collection("dailyActivities").document()
    
    let data: [String: Any] = [
        "date": Timestamp(date: Date()),
        "summary": summary,
        "fullLog": fullLog
    ]
    
    newActivityRef.setData(data) { error in
        if let error = error {
            print("Error logging activity: \(error)")
            completion(false, error)
        } else {
            print("Daily activity logged successfully")
            completion(true, nil)
        }
    }
}

struct LogDailyActivityView_Previews: PreviewProvider {
    static var previews: some View {
        let mockChild = Student(
            id: "123",
            nisn: "1221432423",
            name: "John Doe",
            gender: "Man",
            birthdate: Date(timeIntervalSince1970: 946684800),
            background: "Student",
            emergencyContact: "08621312312312",
            autismLevel: "Intermediate",
            likes: "Sport",
            dislikes: "Vegetable",
            skills: "Basketball",
            imageUrl: nil
        )
        
        NavigationStack {
            LogDailyActivityView(student: mockChild)
        }
    }
}



