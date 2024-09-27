//
//  HomeViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var isAddSheetPresented = false
    @Published var isDocumentationTypeSheetPresented = false
    @Published var navigationPath = NavigationPath()
    @Published var isAddDocumentationPresented = false
    @Published var students: [Student] = []
    
    private let useCase: StudentUseCase
    
    init(useCase: StudentUseCase = StudentUseCase(repository: StudentRepository())) {
        self.useCase = useCase
        loadStudents()
    }
    
    func navigateToDetail(student: Student) {
        navigationPath.append(student)
    }
    
    func loadStudents() {
        students = useCase.getAllStudents()
    }
}
