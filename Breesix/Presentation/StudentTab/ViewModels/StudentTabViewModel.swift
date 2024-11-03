//
//  StudentTabViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import Foundation
import SwiftUI

@MainActor
class StudentTabViewModel: ObservableObject {
    @ObservedObject var studentViewModel: StudentViewModel
    @Published var selectedDate: Date = Date()
    private let summaryService: SummaryService
    private let summaryLlamaService: SummaryLlamaService
    private let summaryUseCase: SummaryUseCase
    
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
