//
//  StudentViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 22/10/24.
//

import Foundation
import SwiftUI

@MainActor
class StudentViewModel: ObservableObject {
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
            await fetchAllStudents()
            
            await MainActor.run {
                self.newStudentImage = nil
                self.compressedImageData = nil
            }
        } catch {
            print("Error adding student: \(error)")
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
