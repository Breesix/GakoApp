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
            throw ProcessingError.noStudentData
        }
        
        let botPrompt = """
        Anda adalah asisten AI ahli dalam menganalisis refleksi harian guru tentang aktivitas murid di sekolah. Tugas Anda adalah mengekstrak informasi penting dan mengorganisirnya dalam format yang terstruktur dan detail.

        Panduan Analisis:
        1. Baca refleksi guru dengan sangat teliti.
        2. Identifikasi setiap murid yang disebutkan dalam refleksi.
        3. Untuk setiap murid yang disebutkan:
           a. Tentukan aktivitas umum berdasarkan informasi yang diberikan. Berikan detail sebanyak mungkin.
           b. Catat informasi spesifik tentang toilet training jika ada, termasuk kemajuan atau tantangan.
           c. Tentukan status toilet training (true/false) berdasarkan informasi yang tersedia.
        4. Untuk murid yang tidak disebutkan dalam refleksi, isi dengan "Tidak ada informasi".

        Format Output:
        Hasilkan output dalam format CSV dengan struktur berikut:
        Nama,Aktivitas Umum,Toilet Training,Status Toilet Training

        Aturan Pengisian:
        - Nama: Nama lengkap murid
        - Aktivitas Umum: Daftar aktivitas dipisahkan dengan "|". Berikan detail spesifik. Contoh: "Bermain puzzle (menyelesaikan puzzle 20 keping)|Mewarnai (fokus pada penggunaan warna-warna cerah)|Bernyanyi (aktif dalam kegiatan musik pagi)|Makan Kuda (anak makan dengan lahap)"
        - Toilet Training: Catatan spesifik tentang toilet training. Jika tidak ada, isi "Tidak ada informasi"
        - Status Toilet Training: "true" jika sudah mandiri, "false" jika masih perlu bantuan, atau "Tidak ada informasi" jika tidak disebutkan

        Contoh Output:
        Nama,Aktivitas Umum,Toilet Training,Status Toilet Training
        Budi Santoso,"Bermain puzzle (menyelesaikan puzzle 20 keping)|Mewarnai (fokus pada penggunaan warna-warna cerah)|Bernyanyi (aktif dalam kegiatan musik pagi)|Makan Kuda (anak makan dengan lahap)","Berhasil ke toilet sendiri 2 kali hari ini",true
        Ani Putri,"Membaca buku (tertarik pada buku cerita hewan)|Bermain balok (membuat menara setinggi 10 balok)","Masih perlu diingatkan, tapi menunjukkan kemajuan",false
        Citra Lestari,"Tidak ada informasi","Tidak ada informasi","Tidak ada informasi"

        Penting:
        - Gunakan HANYA informasi yang secara eksplisit disebutkan dalam refleksi guru.
        - Jangan menambahkan atau mengasumsikan informasi yang tidak ada dalam refleksi.
        - Pastikan semua murid dalam daftar yang diberikan tercantum dalam output, bahkan jika tidak ada informasi untuk mereka.
        - Berikan output CSV yang kaya informasi dan detail, tanpa komentar atau teks tambahan.
        """

        let userInput = """
        Data Murid: \(studentNames)

        Refleksi Guru: \(reflection)
        """

        let fullPrompt = botPrompt + "\n\n" + userInput
        print(fullPrompt)
        let query = ChatQuery(messages: [.init(role: .user, content: fullPrompt)!], model: .gpt4_o_mini)
        
        let result = try await openAI.chats(query: query)
        
        guard let csvString = result.choices.first?.message.content?.string else {
            throw ProcessingError.noContent
        }
        
        if csvString.contains("Tidak ada informasi") && !csvString.contains(",") {
            throw ProcessingError.insufficientInformation
        }
        
        return csvString
    }
}

enum ProcessingError: Error {
    case noStudentData
    case noContent
    case insufficientInformation
    
    var localizedDescription: String {
        switch self {
        case .noStudentData:
            return "Tidak ada data murid tersedia."
        case .noContent:
            return "Tidak ada konten dalam respons."
        case .insufficientInformation:
            return "Refleksi tidak mengandung informasi yang cukup tentang aktivitas murid. Mohon berikan detail lebih spesifik."
        }
    }
}

class CSVParser {
    static func parseNotes(csvString: String, students: [Student]) -> [Note] {
        let rows = csvString.components(separatedBy: .newlines)
        var notes: [Note] = []
        
        print("Total rows in CSV: \(rows.count)")
        
        for (index, row) in rows.dropFirst().enumerated() where !row.isEmpty {
            print("Processing row \(index + 1): \(row)")
            
            let columns = row.components(separatedBy: ",")
            if columns.count >= 4 {
                let name = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let generalActivityString = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let generalActivityPoints = generalActivityString.components(separatedBy: "|").map { "• " + $0.trimmingCharacters(in: .whitespaces) }
                let toiletTraining = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let toiletTrainingStatus = columns[3].lowercased() == "true"
                
                print("Searching for student: \(name)")
                if let student = students.first(where: { $0.fullname.lowercased() == name.lowercased() }) {
                    let newNote = Note(
                        generalActivity: generalActivityPoints.joined(separator: "\n"),
                        toiletTraining: toiletTraining,
                        toiletTrainingStatus: toiletTrainingStatus,
                        student: student
                    )
                    notes.append(newNote)
                    print("Note created for \(student.fullname)")
                } else {
                    print("No matching student found for: \(name)")
                }
            } else {
                print("Invalid column count in row: \(columns.count)")
            }
        }
        
        print("Total notes created: \(notes.count)")
        return notes
    }
}
