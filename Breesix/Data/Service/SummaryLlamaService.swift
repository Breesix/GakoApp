//
//  SummaryLlamaService.swift
//  Breesix
//
//  Created by Rangga Biner on 29/10/24.
//

import Foundation
import SwiftData

class SummaryLlamaService {
    private let apiKey: String
    private let baseURL = "https://integrate.api.nvidia.com/v1/chat/completions"
    private let summaryUseCase: SummaryUseCase
    
    init(apiKey: String, summaryUseCase: SummaryUseCase) {
        self.apiKey = apiKey
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

        Tolong buatkan rangkuman yang singkat, padat, dan informatif. Fokuskan pada perkembangan dan pencapaian siswa, serta area yang mungkin memerlukan perhatian lebih. Rangkuman tidak perlu lebih dari 2-3 kalimat. Tidak perlu menyebutkan tanggal nya. jadikan deskriptif dan langsung berikan jawabannya.
        """
        
        let requestBody: [String: Any] = [
            "model": "meta/llama-3.1-405b-instruct",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.5,
            "max_tokens": 1024,
            "top_p": 1
        ]
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ProcessingError.apiError
        }
        
        let result = try JSONDecoder().decode(LlamaResponse.self, from: data)
        
        guard let summaryContent = result.choices.first?.message.content else {
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

