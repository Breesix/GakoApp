//
//  SummarizationService.swift
//  Breesix
//
//  Created by Rangga Biner on 07/10/24.
//

import Foundation
import OpenAI

class SummarizationService {
    private let openAI: OpenAI
    
    init(apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    func generateWeeklySummary(activities: [Activity], toiletTrainings: [ToiletTraining], student: Student) async throws -> String {
        let activitySummary = activities.map { "\($0.createdAt.formatted()): \($0.generalActivity)" }.joined(separator: "\n")
        let toiletTrainingSummary = toiletTrainings.map { "\($0.createdAt.formatted()): \($0.trainingDetail) - Status: \($0.status ?? false ? "Success" : "Needs Improvement")" }.joined(separator: "\n")
        
        let prompt = """
        Anda adalah asisten AI yang ahli dalam menganalisis perkembangan anak berkebutuhan khusus. Buatlah ringkasan mingguan berdasarkan data aktivitas dan toilet training berikut untuk murid bernama \(student.fullname) (\(student.nickname)):

        Aktivitas:
        \(activitySummary)

        Toilet Training:
        \(toiletTrainingSummary)

        Berikan ringkasan yang informatif dan bermanfaat bagi orang tua dan guru, termasuk:
        1. Pola aktivitas yang menonjol
        2. Perkembangan dalam toilet training
        3. Area yang menunjukkan kemajuan
        4. Area yang mungkin memerlukan perhatian lebih
        5. Saran untuk minggu berikutnya

        Format ringkasan dalam paragraf yang mudah dibaca.
        """

        let query = ChatQuery(messages: [.init(role: .user, content: prompt)!], model: .gpt4_o)
        
        let result = try await openAI.chats(query: query)
        
        guard let summary = result.choices.first?.message.content?.string else {
            throw ProcessingError.noContent
        }
        
        return summary
    }
}
