//
//  SummaryViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import Foundation
import SwiftUI

@MainActor
class SummaryViewModel: ObservableObject {
    @ObservedObject var studentViewModel: StudentViewModel
    private let summaryUseCase: SummaryUseCase
    private let summaryService: SummaryService
    private let summaryLlamaService: SummaryLlamaService
    @Published var selectedDate: Date = Date()
    
    init(studentViewModel: StudentViewModel, summaryUseCase: SummaryUseCase, summaryService: SummaryService, summaryLlamaService: SummaryLlamaService) {
        self.studentViewModel = studentViewModel
        self.summaryUseCase = summaryUseCase
        self.summaryService = summaryService
        self.summaryLlamaService = summaryLlamaService
    }

    func generateAndSaveSummaries(for date: Date) async throws {
        try await summaryService.generateAndSaveSummaries(for: studentViewModel.students, on: date)
    }
    
    func generateAndSaveSummariesLlama(for date: Date) async throws {
        try await summaryLlamaService.generateAndSaveSummaries(for: studentViewModel.students, on: date)
    }

}
