//
//  AddDocumentationViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import Foundation

class AddDocumentationViewModel: ObservableObject {
    @Published var students: [Student] = []
    
    private let useCase: StudentUseCase
    
    init(useCase: StudentUseCase = StudentUseCase(repository: StudentRepository())) {
        self.useCase = useCase
        loadStudents()
    }
    
    func loadStudents() {
        students = useCase.getAllStudents()
    }
}
