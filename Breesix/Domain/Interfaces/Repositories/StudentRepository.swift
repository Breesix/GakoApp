//
//  StudentRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import Foundation

class StudentRepository {
    private var students: [Student] = [
        Student(name: "Rangga"),
        Student(name: "Arshad"),
        Student(name: "Wisnu"),
        Student(name: "Curukuk")
    ]
    
    func getAllStudents() -> [Student] {
        return students
    }
}
