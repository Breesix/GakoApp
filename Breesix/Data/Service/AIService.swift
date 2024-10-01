//
//  AIService.swift
//  Breesix
//
//  Created by Rangga Biner on 01/10/24.
//

import Foundation
import OpenAI

class ReflectionProcessor {
    private let openAI: OpenAI
    
    init(apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    func processReflection(reflection: String, students: [Student]) async throws -> String {
        let studentNames = students.map { $0.fullname }.joined(separator: ", ")
        
        if students.isEmpty {
            throw NSError(domain: "ReflectionProcessor", code: 1, userInfo: [NSLocalizedDescriptionKey: "Tidak ada data murid tersedia."])
        }
        
        let botPrompt = """
        Anda adalah asisten AI yang bertugas menganalisis refleksi harian guru tentang aktivitas murid di sekolah. Tugas Anda adalah mengekstrak informasi penting dan mengorganisirnya dalam format yang terstruktur.

        Panduan Analisis:
        1. Baca refleksi guru dengan seksama.
        2. Identifikasi setiap murid yang disebutkan dalam refleksi.
        3. Untuk setiap murid yang disebutkan:
           a. Tentukan aktivitas umum berdasarkan informasi yang diberikan.
           b. Catat informasi spesifik tentang toilet training jika ada.
           c. Tentukan status toilet training (true/false) jika disebutkan.
        4. Untuk murid yang tidak disebutkan dalam refleksi, isi dengan "Tidak ada informasi".

        Format Output:
        Hasilkan output dalam format CSV dengan struktur berikut:
        Nama,Aktivitas Umum,Toilet Training,Status Toilet Training

        Aturan Pengisian:
        - Nama: Nama lengkap murid
        - Aktivitas Umum: Daftar aktivitas dipisahkan dengan "|". Contoh: "Bermain puzzle|Mewarnai|Bernyanyi"
        - Toilet Training: Catatan spesifik tentang toilet training. Jika tidak ada, isi "Tidak ada informasi"
        - Status Toilet Training: "true", atau "false"

        Contoh Output:
        Nama,Aktivitas Umum,Toilet Training,Status Toilet Training
        Budi Santoso,"Bermain puzzle|Mewarnai|Bernyanyi","Berhasil ke toilet sendiri",true
        Ani Putri,"Membaca buku|Bermain balok","Masih perlu diingatkan",false
        Citra Lestari,"Tidak ada informasi","Tidak ada informasi","Tidak ada informasi"

        Penting:
        - Gunakan HANYA informasi yang secara eksplisit disebutkan dalam refleksi guru.
        - Jangan menambahkan atau mengasumsikan informasi yang tidak ada dalam refleksi.
        - Pastikan semua murid dalam daftar yang diberikan tercantum dalam output, bahkan jika tidak ada informasi untuk mereka.
        - Berikan HANYA output CSV tanpa komentar atau teks tambahan.

        """

        let userInput = """
        Data Murid: \(studentNames)

        Refleksi Guru: \(reflection)
        """

        let fullPrompt = botPrompt + "\n\n" + userInput
        
        print("Prompt: \(fullPrompt)")
        
        let query = ChatQuery(messages: [.init(role: .user, content: fullPrompt)!], model: .gpt4_o_mini)
        
        let result = try await openAI.chats(query: query)
        print("API Response: \(result)")
        
        guard let csvString = result.choices.first?.message.content?.string else {
            throw NSError(domain: "ReflectionProcessor", code: 2, userInfo: [NSLocalizedDescriptionKey: "Tidak ada konten dalam respons."])
        }
        
        if csvString.contains("Tidak ada informasi") && !csvString.contains(",") {
            throw NSError(domain: "ReflectionProcessor", code: 5, userInfo: [NSLocalizedDescriptionKey: "Refleksi tidak mengandung informasi yang cukup tentang aktivitas murid. Mohon berikan detail lebih spesifik."])
        }
        
        return csvString
    }
}


class CSVParser {
    static func parseNotes(csvString: String, students: [Student]) -> [Note] {
        let rows = csvString.components(separatedBy: .newlines)
        var notes: [Note] = []
        
        for row in rows.dropFirst() where !row.isEmpty {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 4 {
                let name = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let generalActivityString = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let generalActivityPoints = generalActivityString.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespaces) }
                let toiletTraining = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let toiletTrainingStatus = columns[3].lowercased() == "true"
                
                if let student = students.first(where: { $0.fullname == name }) {
                    let newNote = Note(
                        generalActivity: generalActivityPoints.joined(separator: "\n• "),
                        toiletTraining: toiletTraining,
                        toiletTrainingStatus: toiletTrainingStatus,
                        student: student
                    )
                    notes.append(newNote)
                }
            }
        }
        
        return notes
    }
}

