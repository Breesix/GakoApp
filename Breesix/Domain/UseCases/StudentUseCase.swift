//
//  StudentUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import Foundation

class StudentUseCase {
    private let repository: StudentRepository
    
    init(repository: StudentRepository) {
        self.repository = repository
    }
    
    func getAllStudents() -> [Student] {
        return repository.getAllStudents()
    }
}
