//
//  SummaryUseCase.swift
//  Breesix
//
//  Created by Rangga Biner on 18/10/24.
//

import Foundation

protocol SummaryUseCase {
    func fetchSummaries(_ student: Student) async throws -> [Summary]
    func addSummary(_ summary: Summary, for student: Student) async throws
    func updateSummary(_ summary: Summary) async throws
    func deleteSummary(_ summary: Summary, from student: Student) async throws
    func fetchSummary(for student: Student, on date: Date) async throws -> Summary?
}
