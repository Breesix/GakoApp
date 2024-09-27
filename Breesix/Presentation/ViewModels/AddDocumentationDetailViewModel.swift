//
//  AddDocumentationDetailViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 27/09/24.
//

import Foundation

class AddDocumentationDetailViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    
    private let useCase: ActivityUseCase
    
    init(useCase: ActivityUseCase = ActivityUseCase(repository: ActivityRepository())) {
        self.useCase = useCase
        loadActivities()
    }
    
    func loadActivities() {
        activities = useCase.getAllSActivities()
    }
}
