//
//  AITTService.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import OpenAI
import SwiftData

class AITTService {
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
        Anda adalah asisten AI yang terlatih dalam menganalisis refleksi harian dari guru mengenai perkembangan latihan toilet training di sekolah, khususnya untuk anak berkebutuhan khusus. Tugas Anda adalah mengekstrak informasi kunci dan menyajikannya dalam format terstruktur dengan detail yang memadai.

        Panduan Analisis:
        1. Bacalah dengan seksama setiap refleksi yang diberikan oleh guru.
        2. Identifikasi semua siswa yang disebutkan dalam refleksi, baik menggunakan nama lengkap maupun nama panggilan.
        3. Apabila nama siswa tidak disebutkan secara langsung, pahami terminologi seperti "semua" yang berarti semua siswa, dan "anak lain" yang berarti semua siswa kecuali mereka yang disebutkan secara eksplisit.
        4. Untuk setiap siswa yang disebutkan, tentukan apakah anak sudah dapat melakukan toilet training dengan baik. lalu lengkapi dengan detail deskripsi dari aktivitas toilet training anak.
        5. Jika ada siswa yang tidak disebutkan dalam refleksi, catat "Tidak ada informasi" untuk mereka, catat null untuk kolom yang bersifat boolean.
        6. Anda tidak perlu menyensor atau menyeleksi isi refleksi, baik yang positif maupun negatif, tetap dicantumkan tanpa modifikasi.
        7. Pastikan untuk memasukkan informasi yang ada tanpa menambahkan asumsi.

        Format Output:
        Hasilkan output dalam format CSV dengan struktur berikut:
        Nama Lengkap,Nama Panggilan,status,deskripsi

        Aturan Pengisian:
        - Nama Lengkap: Nama lengkap siswa.
        - Nama Panggilan: Nama panggilan siswa.
        - Status: Status toilet training anak berupa nilai boolean, true untuk anak yang sudah dapat melakukan dengan mandiri, false apabila masih terdapat masalah atau perlu dibimbing, atau null jika tidak ada informasi
        - deskripsi: Catatan spesifik tentang toilet training. Jika tidak ada, isi ”Tidak ada informasi"

        Contoh Output:
        Nama Lengkap,Nama Panggilan,status,deskripsi
        Budi Santoso,Budi,true,“Sudah bisa pergi ke toilet sendiri dan cebok sendiri. Ia pun mengingatkan temannya untuk menyiram setelah buang air” 
        Ani Putri,Ani,false,”Masih meminta untuk ditemani ke dalam ruangan toilet, namun sudah ada kemajuan”
        Citra Lestari,Citra,null,”Tidak ada informasi"

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

class TTCSVParser {
    static func parseActivities(csvString: String, students: [Student], createdAt: Date) -> [UnsavedActivity] {
        let rows = csvString.components(separatedBy: .newlines)
        var unsavedToiletTrainings: [UnsavedActivity] = []
        
        print("Total rows in CSV: \(rows.count)")
        print("Available students: \(students.map { "\($0.fullname) (\($0.nickname))" })")
        
        for (index, row) in rows.dropFirst().enumerated() where !row.isEmpty {
            print("Processing row \(index + 1): \(row)")
            
            let columns = parseCSVRow(row)
            if columns.count >= 4 {
                let fullName = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let nickname = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let status = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let details = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("Searching for student: \(fullName) (\(nickname))")
                if let student = findMatchingStudent(fullName: fullName, nickname: nickname, in: students) {
                    let trainingStatus: Bool
                    if (status != "null") {
                        if status == "true" {
                            trainingStatus = true
                        } else {
                            trainingStatus = false
                        }
                        let trainingDetail: String = details
                        if !trainingDetail.isEmpty {
                            let unsavedToiletTraining = UnsavedActivity(
                                trainingDetail: trainingDetail,
                                createdAt: createdAt,
                                status: trainingStatus,
                                studentId: student.id
                            )
                            unsavedToiletTrainings.append(unsavedToiletTraining)
                        } else {
                            print("No information available for \(student.fullname) (\(student.nickname))")
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
        
        print("Total training created: \(unsavedToiletTrainings.count)")
        return unsavedToiletTrainings
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
