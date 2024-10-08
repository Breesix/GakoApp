//
//  SummaryRepository.swift
//  Breesix
//
//  Created by Rangga Biner on 08/10/24.
//

import Foundation

protocol SummaryRepository {
    func deleteSummary(_ summary: WeeklySummary, from student: Student) async throws
}

