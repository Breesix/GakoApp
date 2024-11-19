//
//  StudentViewModel.swift
//  Gako
//
//  Created by Rangga Biner on 22/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Core ViewModel for managing student data and analytics
//  Usage: Handles student-related operations including: CRUD operations for student profiles, Image compression and management, Analytics tracking via Mixpanel, Student selection state management
//

import Foundation
import Mixpanel
import SwiftUI

@MainActor
class StudentViewModel: ObservableObject {
    @Published var selectedStudents: Set<Student> = []
    @Published var activities: [String] = []
    @Published var students: [Student] = []
    private let studentUseCases: StudentUseCase
    @Published private(set) var compressedImageData: Data?
    @Published var newStudentImage: UIImage? {
        didSet {
            if let image = newStudentImage {
                self.compressedImageData = image.jpegData(compressionQuality: 0.8)
            } else {
                self.compressedImageData = nil
            }
        }
    }
    private func trackEvent(_ eventName: String, properties: [String: MixpanelType]? = nil) {
        Mixpanel.mainInstance().track(event: eventName, properties: properties)
    }
    
    init(students: [Student] = [], studentUseCases: StudentUseCase, compressedImageData: Data? = nil, newStudentImage: UIImage? = nil) {
        self.students = students
        self.studentUseCases = studentUseCases
        self.compressedImageData = compressedImageData
        self.newStudentImage = newStudentImage
    }
    
    @MainActor
    func fetchAllStudents() async {
        do {
            students = try await studentUseCases.fetchAllStudents()
        } catch {
            print("Error loading students: \(error)")
        }
    }

    @MainActor
    func addStudent(_ student: Student) async {
        do {
            let studentWithCompressedImage = Student(
                fullname: student.fullname,
                nickname: student.nickname,
                imageData: compressedImageData
            )
            
            try await studentUseCases.addStudent(studentWithCompressedImage)
            trackEvent("Student Created", properties: [
                "student_name": student.fullname as MixpanelType,
                "has_image": (compressedImageData != nil) as MixpanelType,
                "timestamp": Date() as MixpanelType
            ])

            await fetchAllStudents()
            
            await MainActor.run {
                self.newStudentImage = nil
                self.compressedImageData = nil
            }
        } catch {
            print("Error adding student: \(error)")
            trackEvent("Student Creation Failed", properties: [
                "error": error.localizedDescription as MixpanelType
            ])
        }
    }
    
    func updateStudent(_ student: Student) async {
        do {
            try await studentUseCases.updateStudent(student)
            await fetchAllStudents()
            
            await MainActor.run {
                self.newStudentImage = nil
                self.compressedImageData = nil
            }
        } catch {
            print("Error updating student: \(error)")
        }
    }

    
    func deleteStudent(_ student: Student) async {
        do {
            try await studentUseCases.deleteStudent(student)
            await fetchAllStudents()
        } catch {
            print("Error deleting student: \(error)")
        }
    }
}
