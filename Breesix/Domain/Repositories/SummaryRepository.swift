//
//  SummaryRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 18/10/24.
//

import Foundation

protocol SummaryRepository {
    func fetchAllSummaries(_ student: Student) async throws -> [Summary]
    func addSummary(_ summary: Summary, for student: Student) async throws
    func updateSummary(_ summary: Summary) async throws
    func deleteSummary(_ summary: Summary, from student: Student) async throws
}
