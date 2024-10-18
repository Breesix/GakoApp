//
//  SummaryRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 18/10/24.
//

import Foundation
import SwiftData

class SummaryRepositoryImpl: SummaryRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
    
    func fetchAllSummaries(_ student: Student) async throws -> [Summary] {
        return student.summaries
    }
    
    func addSummary(_ summary: Summary, for student: Student) async throws {
        student.summaries.append(summary)
        try context.save()
    }
    
    func updateSummary(_ summary: Summary) async throws {
        try context.save()
    }
    
    func deleteSummary(_ summary: Summary, from student: Student) async throws {
        student.summaries.removeAll { $0.id == summary.id }
        context.delete(summary)
        try context.save()

    }
}
