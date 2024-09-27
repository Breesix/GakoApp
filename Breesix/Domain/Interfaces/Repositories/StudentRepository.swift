//
//  StudentRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import Foundation

class StudentRepository {
    private var students: [Student] = [
        Student(name: "Rangga Biner", nickname: "Rangga"),
        Student(name: "Arshad Thareeq", nickname: "Arshad"),
        Student(name: "Wisnu Hadiyasa", nickname: "Wisnu"),
        Student(name: "Curukuk Icikiwir", nickname: "Ici")
    ]
    
    func getAllStudents() -> [Student] {
        return students
    }
}
