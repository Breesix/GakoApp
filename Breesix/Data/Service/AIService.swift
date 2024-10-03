//
//  AIService.swift
//  Breesix
//
//  Created by Rangga Biner on 01/10/24.
//

import Foundation
import OpenAI
import SwiftData

class ReflectionProcessor {
    private let openAI: OpenAI
    
    init(apiToken: String) {
        self.openAI = OpenAI(apiToken: apiToken)
    }
    
    func processReflection(reflection: String, students: [Student]) async throws -> String {
        let studentInfo = students.map { "\($0.fullname) (\($0.nickname))" }.joined(separator: ", ")
        
        if students.isEmpty {
            throw ProcessingError.noStudentData
        }
        
        let botPrompt = """
        Anda adalah asisten AI yang terlatih dalam menganalisis refleksi harian dari guru mengenai aktivitas siswa di sekolah. Tugas Anda adalah mengekstrak informasi kunci dan menyajikannya dalam format terstruktur dengan detail yang memadai.

        Panduan Analisis:
        1. Bacalah dengan seksama setiap refleksi yang diberikan oleh guru.
        2. Identifikasi semua siswa yang disebutkan dalam refleksi, baik menggunakan nama lengkap maupun nama panggilan.
        3. Apabila nama siswa tidak disebutkan secara langsung, pahami terminologi seperti "semua" yang berarti semua siswa, dan "anak lain" yang berarti semua siswa kecuali mereka yang disebutkan secara eksplisit.
        4. Untuk setiap siswa yang disebutkan, tentukan aktivitas umum berdasarkan informasi yang disediakan, lengkapi dengan detail spesifik.
        5. Jika ada siswa yang tidak disebutkan dalam refleksi, catat "Tidak ada informasi" untuk mereka.
        6. Anda tidak perlu menyensor atau menyeleksi isi refleksi, baik yang positif maupun negatif, tetap dicantumkan tanpa modifikasi.
        7. Pastikan untuk memasukkan informasi yang ada tanpa menambahkan asumsi.

        Format Output:
        Hasilkan output dalam format CSV dengan struktur berikut:
        Nama Lengkap,Nama Panggilan,Aktivitas Umum

        Aturan Pengisian:
        - Nama Lengkap: Nama lengkap siswa.
        - Nama Panggilan: Nama panggilan siswa.
        - Aktivitas Umum: Daftar aktivitas yang dipisahkan dengan "|". Contoh: "Bermain puzzle (menyelesaikan puzzle 20 keping)|Mewarnai (fokus pada penggunaan warna-warna cerah)|Bernyanyi (aktif dalam kegiatan musik pagi)|Makan Kuda (anak makan dengan lahap)|Toilet training (berhasil ke toilet sendiri 2 kali hari ini)"

        Contoh Output:
        Nama Lengkap,Nama Panggilan,Aktivitas Umum
        Budi Santoso,Budi,"Bermain puzzle (menyelesaikan puzzle 20 keping)|Mewarnai (fokus pada penggunaan warna-warna cerah)|Bernyanyi (aktif dalam kegiatan musik pagi)|Makan Kuda (anak makan dengan lahap)|Toilet training (berhasil ke toilet sendiri 2 kali hari ini)"
        Ani Putri,Ani,"Membaca buku (tertarik pada buku cerita hewan)|Bermain balok (membuat menara setinggi 10 balok)|Toilet training (masih perlu diingatkan, tapi menunjukkan kemajuan)"
        Citra Lestari,Citra,"Tidak ada informasi"

        Penting:
        - Gunakan HANYA informasi yang secara eksplisit disebutkan dalam refleksi guru.
        - Hindari menambahkan atau membuat asumsi terkait informasi yang tidak tersedia dalam refleksi.
        - Pastikan semua siswa dalam daftar yang diberikan tercantum dalam output, bahkan jika tidak terdapat informasi untuk mereka.
        - Buat output CSV yang informatif dan detail, tanpa tambahan komentar atau teks.
        """
        
        let userInput = """
        Data Murid: \(studentInfo)

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
    static func parseActivities(csvString: String, students: [Student], createdAt: Date) -> [Activity] {
        let rows = csvString.components(separatedBy: .newlines)
        var activities: [Activity] = []
        
        print("Total rows in CSV: \(rows.count)")
        print("Available students: \(students.map { "\($0.fullname) (\($0.nickname))" })")
        
        for (index, row) in rows.dropFirst().enumerated() where !row.isEmpty {
            print("Processing row \(index + 1): \(row)")
            
            let columns = parseCSVRow(row)
            if columns.count >= 3 {
                let fullName = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let nickname = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let generalActivityString = columns[2]
                
                print("Searching for student: \(fullName) (\(nickname))")
                if let student = findMatchingStudent(fullName: fullName, nickname: nickname, in: students) {
                    if generalActivityString.lowercased() != "tidak ada informasi" {
                        let generalActivityPoints = generalActivityString.components(separatedBy: "|")
                        for activity in generalActivityPoints {
                            let trimmedActivity = activity.trimmingCharacters(in: .whitespaces)
                            if !trimmedActivity.isEmpty {
                                let newActivity = Activity(
                                    generalActivity: trimmedActivity,
                                    createdAt: createdAt,
                                    student: student
                                )
                                activities.append(newActivity)
                                print("Activity created for \(student.fullname) (\(student.nickname)): \(trimmedActivity)")
                            }
                        }
                    } else {
                        print("No information available for \(student.fullname) (\(student.nickname))")
                    }
                } else {
                    print("No matching student found for: \(fullName) (\(nickname))")
                }
            } else {
                print("Invalid column count in row: \(columns.count)")
            }
        }
        
        print("Total activities created: \(activities.count)")
        return activities
    }

    
    private static func parseCSVRow(_ row: String) -> [String] {
        var columns: [String] = []
        var currentColumn = ""
        var insideQuotes = false
        
        for character in row {
            if character == "\"" {
                insideQuotes.toggle()
            } else if character == "," && !insideQuotes {
                columns.append(currentColumn)
                currentColumn = ""
            } else {
                currentColumn.append(character)
            }
        }
        
        columns.append(currentColumn)
        return columns
    }
    
    private static func findMatchingStudent(fullName: String, nickname: String, in students: [Student]) -> Student? {
        let normalizedFullName = fullName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedNickname = nickname.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return students.first { student in
            let studentFullName = student.fullname.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            let studentNickname = student.nickname.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            return studentFullName == normalizedFullName || studentNickname == normalizedNickname
        }
    }
}