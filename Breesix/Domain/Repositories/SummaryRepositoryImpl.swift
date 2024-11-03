//
//  SummaryRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 18/10/24.
//

import Foundation

class SummaryRepositoryImpl: SummaryRepository {
    private let dataSource: SummaryDataSource
    
    init(dataSource: SummaryDataSource) {
        self.dataSource = dataSource
    }
    
    func fetchAllSummaries(_ student: Student) async throws -> [Summary] {
        return try await dataSource.fetchAllSummaries(student)
    }
    
    func addSummary(_ summary: Summary, for student: Student) async throws {
        try await dataSource.insert(summary, for: student)
    }
    
    func updateSummary(_ summary: Summary) async throws {
        try await dataSource.update(summary)
    }
    
    func deleteSummary(_ summary: Summary, from student: Student) async throws {
        try await dataSource.delete(summary, from: student)
    }
}
