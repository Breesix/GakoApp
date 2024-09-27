//
//  AgendaListViewModel.swift
//  Breesix
//
//  Created by Akmal Hakim on 24/09/24.
//

import Foundation
import FirebaseFirestore
import CoreData

class AgendaListViewModel: ObservableObject {
    @Published var weeklyTemplate: WeeklyTemplate?
    private let db = Firestore.firestore()
    private let templateCollection = "weeklyTemplates"
    
    @Published var lessonPlans: [Activity] = []
    
    init() {
        loadWeeklyTemplateFromFirebase()
    }
    
    func addLessonPlan(_ lessonPlan: Activity) {
        if var template = weeklyTemplate {
            template.lessons.append(lessonPlan)
            updateWeeklyTemplate(template)
        } else {
            let newTemplate = WeeklyTemplate(id: UUID().uuidString, alphaNumCode: generateAlphaNumCode(), title: "My Weekly Plan", lessons: [lessonPlan])
            saveWeeklyTemplateToFirebase(newTemplate)
            updateWeeklyTemplate(newTemplate)
        }
    }
    
    func filterLessonPlans(for day: String, from plans: [Activity]) -> [Activity] {
        return plans.filter { $0.days.contains(day) }
    }
    
    private func generateAlphaNumCode() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
    
    func fetchWeeklyTemplateByCode(_ code: String, completion: @escaping (Bool) -> Void) {
        let documentRef = db.collection(templateCollection).document(code)
        
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data(), let loadedTemplate = self.decodeWeeklyTemplate(from: data) {
                    DispatchQueue.main.async {
                        self.weeklyTemplate = loadedTemplate
                        completion(true)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func loadWeeklyTemplateFromFirebase() {
        let userID = getUserID()
        let documentRef = db.collection(templateCollection).document(userID)
        
        documentRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data(), let loadedTemplate = self.decodeWeeklyTemplate(from: data) {
                    DispatchQueue.main.async {
                        self.weeklyTemplate = loadedTemplate
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let newTemplate = self.createNewWeeklyTemplate()
                    self.weeklyTemplate = newTemplate
                    self.saveWeeklyTemplateToFirebase(newTemplate)
                }
            }
        }
    }
    
    private func createNewWeeklyTemplate() -> WeeklyTemplate {
        let newTemplate = WeeklyTemplate(id: UUID().uuidString, alphaNumCode: generateAlphaNumCode(), title: "My Weekly Plan", lessons: [])
        saveWeeklyTemplateToFirebase(newTemplate)
        return newTemplate
    }
    
    private func saveWeeklyTemplateToFirebase(_ template: WeeklyTemplate) {
        let userID = getUserID()
        let documentRef = db.collection(templateCollection).document(userID)
        
        do {
            let data = try JSONEncoder().encode(template)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                documentRef.setData(jsonObject) { error in
                    if let error = error {
                        print("Error saving template to Firestore: \(error)")
                    } else {
                        print("Template successfully saved to Firestore.")
                    }
                }
            }
        } catch {
            print("Error encoding template: \(error)")
        }
    }
    
    private func decodeWeeklyTemplate(from data: [String: Any]) -> WeeklyTemplate? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let template = try JSONDecoder().decode(WeeklyTemplate.self, from: jsonData)
            return template
        } catch {
            print("Error decoding template: \(error)")
            return nil
        }
    }
    
    private func getUserID() -> String {
        return "Zk3yv47TvmeJsZCE0XmT"
    }
    
    func updateWeeklyTemplate(_ updatedTemplate: WeeklyTemplate) {
        self.weeklyTemplate = updatedTemplate
        saveWeeklyTemplateToFirebase(updatedTemplate)
    }
}

//class AgendaListViewModel: ObservableObject {
//    @Published var weeklyTemplate: WeeklyTemplate?
//    private let db = Firestore.firestore()
//    private let templateCollection = "weeklyTemplates" // Firestore collection name
//
//    init() {
//        loadWeeklyTemplateFromFirebase()
//    }
//
//    // Load WeeklyTemplate from Firebase or create a new one if it doesn't exist
//    private func loadWeeklyTemplateFromFirebase() {
//        let userID = getUserID() // Get the current user's ID (could be from Firebase Auth or other method)
//        let documentRef = db.collection(templateCollection).document(userID)
//
//        documentRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                // WeeklyTemplate found in Firestore, load it
//                if let data = document.data(), let loadedTemplate = self.decodeWeeklyTemplate(from: data) {
//                    DispatchQueue.main.async {
//                        self.weeklyTemplate = loadedTemplate
//                    }
//                }
//            } else {
//                // WeeklyTemplate not found, create a new one
//                DispatchQueue.main.async {
//                    let newTemplate = self.createNewWeeklyTemplate()
//                    self.weeklyTemplate = newTemplate
//                    self.saveWeeklyTemplateToFirebase(newTemplate)
//                }
//            }
//        }
//    }
//
//    // Method to create a new WeeklyTemplate
//    private func createNewWeeklyTemplate() -> WeeklyTemplate {
//        let newTemplate = WeeklyTemplate(id: UUID().uuidString, title: "My Weekly Plan", lessons: [])
//        return newTemplate
//    }
//
//    // Method to save WeeklyTemplate to Firestore
//    private func saveWeeklyTemplateToFirebase(_ template: WeeklyTemplate) {
//        let userID = getUserID() // Get the current user's ID
//        let documentRef = db.collection(templateCollection).document(userID)
//
//        do {
//            let data = try JSONEncoder().encode(template)
//            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                documentRef.setData(jsonObject) { error in
//                    if let error = error {
//                        print("Error saving template to Firestore: \(error)")
//                    } else {
//                        print("Template successfully saved to Firestore.")
//                    }
//                }
//            }
//        } catch {
//            print("Error encoding template: \(error)")
//        }
//    }
//
//    // Decode WeeklyTemplate from Firestore document data
//    private func decodeWeeklyTemplate(from data: [String: Any]) -> WeeklyTemplate? {
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: data)
//            let template = try JSONDecoder().decode(WeeklyTemplate.self, from: jsonData)
//            return template
//        } catch {
//            print("Error decoding template: \(error)")
//            return nil
//        }
//    }
//
//    // Method to get user ID (stub for example purposes, replace with your user ID logic)
//    private func getUserID() -> String {
//        // Use FirebaseAuth or another method to get a unique user identifier
//        return "example_user_id"
//    }
//
//    // Update WeeklyTemplate in Firebase
//    func updateWeeklyTemplate(_ updatedTemplate: WeeklyTemplate) {
//        self.weeklyTemplate = updatedTemplate
//        saveWeeklyTemplateToFirebase(updatedTemplate)
//    }
//}


//class AgendaListViewModel: ObservableObject {
//    @Published var showAddActivity: Bool = false
//    @Published var lessonPlans: [LessonPlanTemplate] = [] {
//        didSet {
//            saveToUserDefaults()
//        }
//    }
//    @Published var selectedDate = Date()
//    @Published var filteredLessonPlans: [LessonPlanTemplate] = []
//
//    let db = Firestore.firestore()
//
//    init() {
//        loadFromUserDefaults()
//    }
//
//    func saveToUserDefaults() {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(lessonPlans) {
//            UserDefaults.standard.set(encoded, forKey: "lessonPlans")
//        }
//    }
//
//    // Save the weekly template to Firestore
//    func saveWeeklyTemplate(_ weeklyTemplate: WeeklyTemplate) {
//        do {
//            try db.collection("weeklyTemplates").document(weeklyTemplate.alphaNumCode).setData(from: weeklyTemplate)
//        } catch let error {
//            print("Error saving weekly template: \(error)")
//        }
//    }
//
//    func loadFromUserDefaults() {
//        if let savedData = UserDefaults.standard.data(forKey: "lessonPlans"),
//           let decoded = try? JSONDecoder().decode([LessonPlanTemplate].self, from: savedData) {
//            lessonPlans = decoded
//        }
//    }
//
//    func addLessonPlan(_ lessonPlan: LessonPlanTemplate) {
//        WeeklyTemplate.lessons.append(lessonPlan) [THIS STILL WRONG]
//        saveToUserDefaults()
//    }
//
//    // Filter lesson plans by day
//    func filterLessonPlans(for day: String, from lessonPlans: [LessonPlanTemplate]) -> [LessonPlanTemplate] {
//        return lessonPlans.filter { $0.days.contains(day) }
//    }
//
//    // Fetch weekly template using alphanumeric code
//    func fetchWeeklyTemplateByCode(_ code: String, completion: @escaping (WeeklyTemplate?) -> Void) {
//        let docRef = db.collection("weeklyTemplates").document(code)
//        docRef.getDocument { (document, error) in
//            if let document = document, document.exists {
//                do {
//                    let weeklyTemplate = try document.data(as: WeeklyTemplate.self)
//                    completion(weeklyTemplate)
//                } catch let error {
//                    print("Error decoding weekly template: \(error)")
//                    completion(nil)
//                }
//            } else {
//                print("Weekly template not found")
//                completion(nil)
//            }
//        }
//    }
//}
//
//
