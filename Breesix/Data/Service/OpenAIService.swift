//
//  OpenAIService.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation
import OpenAI
import SwiftData

class OpenAIService {
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
        Saya ingin Anda membantu saya menghasilkan format CSV berdasarkan curhatan harian seorang guru mengenai aktivitas siswa di sekolah. Berikut adalah panduan yang harus Anda ikuti:

        1. Bacalah curhatan dengan seksama dan identifikasi semua siswa yang disebutkan dalam curhatan, baik dengan nama lengkap maupun nama panggilan.
        2. Ekstrak semua aktivitas yang tercantum dalam curhatan untuk setiap siswa.
        3. Tentukan untuk setiap aktivitas apakah siswa melakukannya secara "mandiri" atau "dibimbing”. Jika Mandiri = True, Jika Dibimbing = False.
        Jika ada indikasi pengecualian, maka bukan berarti murid tersebut tidak melakukan aktivitas tersebut. Misal “Semua anak Bermain Balok dengan hebat kecuali Rangga“ atau “Semua anak kecuali Rangga Bermain Balok dengan hebat” maka dalam kasus ini status kemandirian Rangga adalah “Bermain Balok (false)”
        5. Jika suatu aktivitas tidak disebutkan untuk siswa tertentu, isikan status kemandirian aktivitas tersebut dengan "null".
        6. Tambahkan kolom "Curhatan" yang menggambarkan kesan atau komentar guru tentang masing-masing siswa terkait kegiatan yang dilakukan.
        7. Pastikan hanya mencantumkan aktivitas yang disebutkan dalam curhatan tanpa menambahkan aktivitas lain.
        8. Format output harus dalam bentuk CSV dengan kolom sesuai dengan Input User:
        - Nama Lengkap
        - Nama Panggilan
        - Aktivitas (status kemandirian)
        - Curhatan 
        9. Output adalah berupa CSV saja

        Contoh Versi 1:

        **Contoh Input:**
        Nama Murid: Rangga Hadi (Rangga), Joko Sambodo (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “Semua anak upacara dengan disiplin, lalu mereka memotong kuku sendiri kecuali JokSa yang harus digunting kukunya oleh gurunya."

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
        Rangga Hadi,Rangga,"Upacara (true)|Memotong kuku (true)", "Rangga menunjukkan kedisiplinan dalam upacara."
        Joko Sambodo,JokSa,"Upacara (true)|Memotong kuku (false)", "JokSa perlu banyak latih diri agar bisa mandiri."
        Samuel Suharto,Samuel,”Upacara (true)|Memotong kuku (true)", “Samuel disiplin saat upacara dan bisa melakukannya sendiri.”
        ```

        Contoh versi 2:

        **Contoh Input:**
        Nama Murid: Rangga Hadi (Rangga), Joko Sambodo (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “Semua anak kecuali JokSa upacara dengan disiplin."

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
        Rangga Hadi,Rangga,"Upacara (true)”, "Rangga menunjukkan kedisiplinan dalam upacara."
        Joko Sambodo,JokSa,"Upacara (false)”, "JokSa perlu banyak latih diri agar bisa disiplin.”
        Samuel Suharto,Samuel,”Upacara (true)", “Samuel disiplin saat upacara dan bisa melakukannya sendiri.”
        ```


        Contoh versi 3:

        **Contoh Input:**
        Nama Murid: Rangga Hadi (Rangga), Joko Sambodo (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “Rangga Upacara dengan baik. Semua anak bernyanyi dengan sangat baik dan merdu”

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
        Rangga Hadi,Rangga,"Upacara (true)|Menyanyi (true)”, "Rangga menunjukkan kedisiplinan dalam upacara dan menyanyi sangat merdu.”
        Joko Sambodo,JokSa,"Upacara (null)|Menyanyi (true)”, "Joko menyanyi sangat merdu."
        Samuel Suharto,Samuel,”Upacara (null)|Menyanyi (true)”, “Samuel Menyanyi Sangat Merdu.”
        ```

        Contoh Versi 4:

        **Contoh Input:**
        Nama Murid: Rangga Hadi (Rangga), Joko Sambodo (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “Rangga Upacara dengan baik dan Samuel bernyanyi dengan butuh bimbingan”

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
        Rangga Hadi,Rangga,"Upacara (true)|Menyanyi (null)”, "Rangga menunjukkan kedisiplinan dalam upacara.”
        Joko Sambodo,JokSa,"Upacara (null)|Menyanyi (null)”, "Tidak ada informasi satupun."
        Samuel Suharto,Samuel,”Upacara (null)|Menyanyi (false)”, “Tidak ada informasi satupun.”
        ```

        Contoh Versi 5:

        **Contoh Input:**
        Nama Murid: Rangga Hadi (Rangga), Joko Sambodo (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “Rangga Upacara dengan baik”

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
        Rangga Hadi,Rangga,"Upacara (true)”, "Rangga menunjukkan kedisiplinan dalam upacara.”
        Joko Sambodo,JokSa,"Upacara (null)”, "Tidak ada informasi satupun."
        Samuel Suharto,Samuel,”Upacara (null)”, “Tidak ada informasi satupun.”
        ```

        Contoh Versi 6:
        **Contoh Input:**
        Nama Murid: Rangga Hadi (Rangga), Joko Sambodo (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “woy gw mau curhat huhuhu semua anak kecuali Joko upacara dengan sangat hebatttt. Adapun Samuel tadi senamnya memerlukan bantuan untuk gerakan khusus seperti tepuk tangan dalam senam”

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
        Rangga Hadi,Rangga,"Upacara (true)|Senam (null)”, "Rangga menunjukkan kedisiplinan dalam upacara.”
        Joko Sambodo,JokSa,"Upacara (false)|Senam (null)”, “Joko membutuhkan bimbingan dalam upacara.”
        Samuel Suharto,Samuel,”Upacara (true)|Senam (false)”, “Samuel Menunjukkan kedisplinan pada saat upacara dan membutuhkan bimbingan dalam senam seperti pada gerakan tepuk tangan dalam senam.”
        ```

        ————

        """
        
        let userInput = """
        INPUT USER:
        Input User yang harus anda analisis adalah:

        Data Murid: \(studentInfo)

        Curhatan Guru: \(reflection)
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

class ReflectionCSVParser {
    static func parseActivitiesAndNotes(csvString: String, students: [Student], createdAt: Date) -> ([UnsavedActivity], [UnsavedNote]) {
        let rows = csvString.components(separatedBy: .newlines)
        var unsavedActivities: [UnsavedActivity] = []
        var unsavedNotes: [UnsavedNote] = []
        
        print("Total rows in CSV: \(rows.count)")
        print("Available students: \(students.map { "\($0.fullname) (\($0.nickname))" })")
        
        for (index, row) in rows.dropFirst().enumerated() where !row.isEmpty {
            print("Processing row \(index + 1): \(row)")
            
            let columns = parseCSVRow(row)
            if columns.count >= 4 {
                let fullName = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let nickname = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let activitiesString = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let curhatan = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("Searching for student: \(fullName) (\(nickname))")
                if let student = findMatchingStudent(fullName: fullName, nickname: nickname, in: students) {
                    let activities = activitiesString.components(separatedBy: "|")
                    for activity in activities {
                        let parts = activity.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: "(")
                        if parts.count == 2 {
                            let activityName = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let statusString = parts[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ")", with: "")
                            
                            let isIndependent: Bool?
                            switch statusString.lowercased() {
                            case "true":
                                isIndependent = true
                            case "false":
                                isIndependent = false
                            default:
                                isIndependent = nil
                            }
                            
                            let unsavedActivity = UnsavedActivity(
                                activity: activityName,
                                createdAt: createdAt,
                                isIndependent: isIndependent,
                                studentId: student.id
                            )
                            unsavedActivities.append(unsavedActivity)
                        }
                    }
                        let unsavedNote = UnsavedNote(
                            note: curhatan,
                            createdAt: createdAt,
                            studentId: student.id
                        )
                        unsavedNotes.append(unsavedNote)
                     
                    print("No matching student found for: \(fullName) (\(nickname))")
                }
            } else {
                print("Invalid column count in row: \(columns.count)")
            }
        }
        
        print("Total activities created: \(unsavedActivities.count)")
        print("Total notes created: \(unsavedNotes.count)")
        return (unsavedActivities, unsavedNotes)
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
