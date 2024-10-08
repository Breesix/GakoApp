//
//  SummarizationService.swift
//  Breesix
//
//  Created by Rangga Biner on 08/10/24.
//

import Foundation
import OpenAI

import Foundation
import OpenAI

class SummarizationService {
    private let openAI: OpenAI
    
    init(apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    func generateWeeklySummary(activities: [Activity], toiletTrainings: [ToiletTraining], student: Student, startDate: Date, endDate: Date) async throws -> String {
        let activitySummary = activities.map { "\($0.createdAt.formatted()): \($0.generalActivity)" }.joined(separator: "\n")
        let toiletTrainingSummary = toiletTrainings.map { "\($0.createdAt.formatted()): \($0.trainingDetail) - Status: \($0.status ?? false ? "Success" : "Needs Improvement")" }.joined(separator: "\n")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let timeRangeDescription = getTimeRangeDescription(from: startDate, to: endDate)
        
        let prompt = """
        Anda adalah asisten AI yang ahli dalam menganalisis perkembangan anak berkebutuhan khusus. Buatlah ringkasan \(timeRangeDescription) berdasarkan data aktivitas dan toilet training berikut untuk murid bernama \(student.fullname) (\(student.nickname)):

        Periode: \(dateFormatter.string(from: startDate)) sampai \(dateFormatter.string(from: endDate))

        Aktivitas:
        \(activitySummary)

        Toilet Training:
        \(toiletTrainingSummary)

        Berikan ringkasan yang informatif dan bermanfaat bagi orang tua dan guru, termasuk:
        1. Pola aktivitas yang menonjol selama periode ini
        2. Perkembangan dalam toilet training
        3. Area yang menunjukkan kemajuan signifikan
        4. Area yang mungkin memerlukan perhatian lebih
        5. Tren atau perubahan yang terlihat selama periode ini
        6. Saran untuk periode berikutnya

        Jika periode waktunya lebih dari satu bulan, fokuskan pada perubahan dan perkembangan jangka panjang.
        Format ringkasan dalam paragraf yang mudah dibaca, dengan penekanan pada informasi yang paling relevan untuk periode waktu ini.
        """

        let query = ChatQuery(messages: [.init(role: .user, content: prompt)!], model: .gpt4_o)
        
        let result = try await openAI.chats(query: query)
        
        guard let summary = result.choices.first?.message.content?.string else {
            throw ProcessingError.noContent
        }
        
        return summary
    }
    
    private func getTimeRangeDescription(from startDate: Date, to endDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month], from: startDate, to: endDate)
        
        if let days = components.day, days <= 7 {
            return "mingguan"
        } else if let days = components.day, days <= 30 {
            return "bulanan"
        } else if let months = components.month, months <= 3 {
            return "tiga bulanan"
        } else if let months = components.month, months <= 6 {
            return "enam bulanan"
        } else {
            return "jangka panjang"
        }
    }
}
