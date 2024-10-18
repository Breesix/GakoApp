//
//  SummaryUseCaseImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 18/10/24.
//

import Foundation

struct SummaryUseCaseImpl: SummaryUseCase {
    let repository: SummaryRepository

    func fetchSummaries(_ student: Student) async throws -> [Summary] {
        return try await repository.fetchAllSummaries(student)
    }
    
    func addSummary(_ summary: Summary, for student: Student) async throws {
        try await repository.addSummary(summary, for: student)
    }
    
    func updateSummary(_ summary: Summary) async throws {
        try await repository.updateSummary(summary)
    }
    
    func deleteSummary(_ summary: Summary, from student: Student) async throws {
        try await repository.deleteSummary(summary, from: student)
    }
    
    func fetchSummary(for student: Student, on date: Date) async throws -> Summary? {
        let summaries = try await repository.fetchAllSummaries(student)
        return summaries.first { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }
    }

}
