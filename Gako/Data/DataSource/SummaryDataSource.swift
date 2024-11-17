//
//  SummaryDataSource.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation

protocol SummaryDataSource {
    func fetchAllSummaries(_ student: Student) async throws -> [Summary]
    func insert(_ summary: Summary, for student: Student) async throws
    func update(_ summary: Summary) async throws
    func delete(_ summary: Summary, from student: Student) async throws
}

