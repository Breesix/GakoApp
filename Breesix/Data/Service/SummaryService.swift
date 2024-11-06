//
//  SummaryService.swift
//  Breesix
//
//  Created by Rangga Biner on 18/10/24.
//

import Foundation
import OpenAI
import SwiftData

class SummaryService {
    private let openAI: OpenAI
    private let summaryUseCase: SummaryUseCase
    
    init(apiToken: String, summaryUseCase: SummaryUseCase) {
        self.openAI = OpenAI(apiToken: apiToken)
        self.summaryUseCase = summaryUseCase
    }
    
    func generateAndSaveSummaries(for students: [Student], on date: Date) async throws {
          let studentSummaries = try await generateStudentSummaries(for: students, on: date)
          
          for (student, summaryContent) in studentSummaries {
              if let existingSummary = try await summaryUseCase.fetchSummary(for: student, on: date) {
                  existingSummary.summary = summaryContent
                  try await summaryUseCase.updateSummary(existingSummary)
              } else {
                  let newSummary = Summary(summary: summaryContent, createdAt: date, student: student)
                  try await summaryUseCase.addSummary(newSummary, for: student)
              }
          }
      }
    private func generateStudentSummaries(for students: [Student], on date: Date) async throws -> [(Student, String)] {
        var studentSummaries: [(Student, String)] = []
        
        for student in students {
            let summary = try await generateIndividualSummary(for: student, on: date)
            studentSummaries.append((student, summary))
        }
        
        return studentSummaries
    }
    
    private func generateIndividualSummary(for student: Student, on date: Date) async throws -> String {
        let activities = student.activities.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }
        let notes = student.notes.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }
        
        let activityDescriptions = activities.map { "\($0.activity) (Mandiri: \($0.status))" }
        let noteDescriptions = notes.map { $0.note }
        
        let prompt = """
        Buatkan rangkuman singkat kegiatan siswa bernama \(student.fullname) (\(student.nickname)) pada tanggal \(formatDate(date)). Berikut adalah data kegiatannya:

        Kegiatan:
        \(activityDescriptions.joined(separator: "\n"))

        Catatan:
        \(noteDescriptions.joined(separator: "\n"))

        Tolong buatkan rangkuman yang singkat, padat, dan informatif. Fokuskan pada perkembangan dan pencapaian siswa, serta area yang mungkin memerlukan perhatian lebih. Rangkuman tidak perlu lebih dari 2-3 kalimat. Tidak perlu menyebutkan tanggal nya.
        """
        
        let query = ChatQuery(messages: [.init(role: .user, content: prompt)!], model: .gpt4_o_mini)
        
        let result = try await openAI.chats(query: query)
        
        guard let summaryContent = result.choices.first?.message.content?.string else {
            throw ProcessingError.noContent
        }
        print(prompt)
        return summaryContent
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
}
