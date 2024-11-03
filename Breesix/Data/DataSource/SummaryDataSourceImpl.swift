//
//  SummaryDataSourceImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation
import SwiftData

class SummaryDataSourceImpl: SummaryDataSource {
    private let modelContext: ModelContext
    
    init(context: ModelContext) {
        self.modelContext = context
    }
    
    func fetchAllSummaries(_ student: Student) async throws -> [Summary] {
        return student.summaries
    }
    
    func insert(_ summary: Summary, for student: Student) async throws {
        student.summaries.append(summary)
        try modelContext.save()
    }
    
    func update(_ summary: Summary) async throws {
        try modelContext.save()
    }
    
    func delete(_ summary: Summary, from student: Student) async throws {
        student.summaries.removeAll { $0.id == summary.id }
        modelContext.delete(summary)
        try modelContext.save()
    }
}

