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
    
    init(apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    func processSummaries(for students: [Student], on date: Date) async throws -> [Summary] {
        var summaries: [Summary] = []
        
        for student in students {
            let summaryContent = try await processSummary(student: student, date: date)
            let summary = SummaryParser.parseSummary(
                summaryString: summaryContent,
                student: student,
                createdAt: date
            )
            summaries.append(summary)
        }
        
        return summaries
    }
    
    private func processSummary(student: Student, date: Date) async throws -> String {
        let activities = student.activities.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }
        let notes = student.notes.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }
        
        let activityDescriptions = activities.map { "\($0.activity) (Mandiri: \($0.isIndependent ?? false))" }
        let noteDescriptions = notes.map { $0.note }
        
        let botPrompt = """
        Anda adalah asisten AI yang akan membantu membuat rangkuman kegiatan siswa. Berikut adalah panduan yang harus diikuti:

        1. Buat rangkuman yang singkat, padat, dan informatif
        2. Fokuskan pada perkembangan dan pencapaian siswa
        3. Identifikasi area yang memerlukan perhatian lebih
        4. Rangkuman tidak lebih dari 2-3 kalimat
        5. Tidak perlu menyebutkan tanggal
        6. Gunakan bahasa yang positif dan konstruktif
        7. Sertakan informasi tentang kemandirian siswa dalam melakukan aktivitas
        8. Jika tidak ada data aktivitas atau catatan, berikan pesan "Tidak ada data aktivitas untuk hari ini"
        """
        
        let userInput = """
        Data Siswa: \(student.fullname) (\(student.nickname))
        
        Kegiatan:
        \(activityDescriptions.joined(separator: "\n"))
        
        Catatan:
        \(noteDescriptions.joined(separator: "\n"))
        """
        
        let fullPrompt = botPrompt + "\n\n" + userInput
        let query = ChatQuery(messages: [.init(role: .user, content: fullPrompt)!], model: .gpt4_o_mini)
        
        let result = try await openAI.chats(query: query)
        
        guard let summaryContent = result.choices.first?.message.content?.string else {
            throw ProcessingError.noContent
        }
        
        if activities.isEmpty && notes.isEmpty {
            throw ProcessingError.insufficientInformation
        }
        
        return summaryContent
    }
}

class SummaryParser {
    static func parseSummary(summaryString: String, student: Student, createdAt: Date) -> Summary {
        return Summary(
            summary: summaryString,
            createdAt: createdAt,
            student: student
        )
    }
    
    static func parseSummaries(summaryStrings: [(Student, String)], createdAt: Date) -> [Summary] {
        return summaryStrings.map { student, summaryString in
            Summary(
                summary: summaryString,
                createdAt: createdAt,
                student: student
            )
        }
    }
}
