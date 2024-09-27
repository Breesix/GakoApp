//
//  AddLessonPlanViewModel.swift
//  Breesix
//
//  Created by Akmal Hakim on 24/09/24.
//

import Foundation
import FirebaseFirestore

class AddLessonPlanViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var selectedDays: [String] = []
    @Published var alphaNumCode: String = ""
    @Published var weeklyTemplate: WeeklyTemplate?
    
    let db = Firestore.firestore()
    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]

    func createLessonPlan() -> Activity {
        return Activity(id: UUID(), title: title, description: description, days: selectedDays)
    }

    func createWeeklyTemplate(completion: @escaping (Bool) -> Void) {
        let newWeeklyTemplate = WeeklyTemplate(id: UUID().uuidString, alphaNumCode: generateAlphaNumCode(), title: title, lessons: [createLessonPlan()])
        saveWeeklyTemplateToFirebase(newWeeklyTemplate) { success in
            if success {
                DispatchQueue.main.async {
                    self.weeklyTemplate = newWeeklyTemplate
                }
            }
            completion(success)
        }
    }

    private func generateAlphaNumCode() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }

    func saveWeeklyTemplateToFirebase(_ weeklyTemplate: WeeklyTemplate, completion: @escaping (Bool) -> Void) {
        do {
            try db.collection("weeklyTemplates").document(weeklyTemplate.alphaNumCode).setData(from: weeklyTemplate) { error in
                if let error = error {
                    print("Error saving weekly template: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print("Weekly template successfully saved.")
                    completion(true)
                }
            }
        } catch let error {
            print("Error saving weekly template: \(error.localizedDescription)")
            completion(false)
        }
    }

    func fetchWeeklyTemplateByCode(_ code: String, completion: @escaping (WeeklyTemplate?) -> Void) {
        let docRef = db.collection("weeklyTemplates").document(code)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let template = try document.data(as: WeeklyTemplate.self)
                    DispatchQueue.main.async {
                        self.weeklyTemplate = template
                    }
                    completion(template)
                } catch let error {
                    print("Error decoding weekly template: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                print("Weekly template not found")
                completion(nil)
            }
        }
    }

    func updateWeeklyTemplateAlphaNumCode(_ newCode: String, completion: @escaping (Bool) -> Void) {
        guard var template = weeklyTemplate else {
            completion(false)
            return
        }

        template.alphaNumCode = newCode

        saveWeeklyTemplateToFirebase(template) { success in
            if success {
                DispatchQueue.main.async {
                    self.weeklyTemplate = template
                }
            }
            completion(success)
        }
    }
}

//class AddLessonPlanViewModel: ObservableObject {
//    @Published var title: String = ""
//    @Published var description: String = ""
//    @Published var selectedDays: [String] = []
//    @Published var alphaNumCode: String = "" // for sharing
//    @Published var weeklyTemplate: WeeklyTemplate?
//    
//    let db = Firestore.firestore()
//    let daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
//
//    // MARK: - Create a Lesson Plan
//    func createLessonPlan() -> LessonPlanTemplate {
//        return LessonPlanTemplate(id: UUID(), title: title, description: description, days: selectedDays)
//    }
//
//    // MARK: - Create a New Weekly Template with a Generated Alphanumeric Code
//    func createWeeklyTemplate(completion: @escaping (Bool) -> Void) {
//        let newWeeklyTemplate = WeeklyTemplate(id: UUID(), alphaNumCode: generateAlphaNumCode(), title: title, lessons: [createLessonPlan()])
//        saveWeeklyTemplateToFirebase(newWeeklyTemplate) { success in
//            if success {
//                DispatchQueue.main.async {
//                    self.weeklyTemplate = newWeeklyTemplate
//                }
//            }
//            completion(success)
//        }
//    }
//
//    // MARK: - Generate an Alphanumeric Code for Sharing
//    private func generateAlphaNumCode() -> String {
//        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        return String((0..<6).map { _ in letters.randomElement()! })
//    }
//
//    // MARK: - Save Weekly Template to Firestore
//    func saveWeeklyTemplateToFirebase(_ weeklyTemplate: WeeklyTemplate, completion: @escaping (Bool) -> Void) {
//        do {
//            try db.collection("weeklyTemplates").document(weeklyTemplate.alphaNumCode).setData(from: weeklyTemplate) { error in
//                if let error = error {
//                    print("Error saving weekly template: \(error.localizedDescription)")
//                    completion(false)
//                } else {
//                    print("Weekly template successfully saved.")
//                    completion(true)
//                }
//            }
//        } catch let error {
//            print("Error saving weekly template: \(error.localizedDescription)")
//            completion(false)
//        }
//    }
//
//    // MARK: - Fetch the Weekly Template Using the Alphanumeric Code
//    func fetchWeeklyTemplateByCode(_ code: String, completion: @escaping (WeeklyTemplate?) -> Void) {
//        let docRef = db.collection("weeklyTemplates").document(code)
//        docRef.getDocument { document, error in
//            if let document = document, document.exists {
//                do {
//                    let template = try document.data(as: WeeklyTemplate.self)
//                    DispatchQueue.main.async {
//                        self.weeklyTemplate = template
//                    }
//                    completion(template)
//                } catch let error {
//                    print("Error decoding weekly template: \(error.localizedDescription)")
//                    completion(nil)
//                }
//            } else {
//                print("Weekly template not found")
//                completion(nil)
//            }
//        }
//    }
//
//    // MARK: - Update Weekly Template with New Alphanumeric Code
//    func updateWeeklyTemplateAlphaNumCode(_ newCode: String, completion: @escaping (Bool) -> Void) {
//        guard var template = weeklyTemplate else {
//            completion(false)
//            return
//        }
//
//        template.alphaNumCode = newCode
//
//        saveWeeklyTemplateToFirebase(template) { success in
//            if success {
//                DispatchQueue.main.async {
//                    self.weeklyTemplate = template
//                }
//            }
//            completion(success)
//        }
//    }
//}
