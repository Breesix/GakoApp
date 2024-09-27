//
//  ActivityUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 27/09/24.
//

import Foundation

class ActivityUseCase {
    private let repository: ActivityRepository
    
    init(repository: ActivityRepository) {
        self.repository = repository
    }
    
    func getAllSActivities() -> [Activity] {
        return repository.getAllActivities()
    }
}
