//
//  SummaryUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 08/10/24.
//

import Foundation

struct SummaryUseCase {
    let repository: SummaryRepository
    
    func deleteSummary(_ summary: WeeklySummary, from student: Student) async throws {
        try await repository.deleteSummary(summary, from: student)
    }

}

