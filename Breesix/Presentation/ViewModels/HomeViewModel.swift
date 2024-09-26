//
//  HomeViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var isAddSheetPresented = false
    @Published var isAddDocumentationPresented = false
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
