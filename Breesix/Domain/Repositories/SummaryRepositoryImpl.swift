//
//  SummaryRepositoryImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 08/10/24.
//
import Foundation
import SwiftData

class SummaryRepositoryImpl: SummaryRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
    
    func deleteSummary(_ summary: WeeklySummary, from student: Student) async throws {
        student.weeklySummaries.removeAll { $0.id == summary.id }
        context.delete(summary)
        try context.save()
    }

}
