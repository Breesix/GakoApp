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
        3. Tentukan untuk setiap aktivitas dengan aturan berikut:
           - "mandiri" = true (jika siswa melakukan sendiri)
           - "dibimbing" = false (jika siswa membutuhkan bantuan)
           - "tidak melakukan" = null (jika siswa tidak disebutkan dalam aktivitas tersebut atau eksplisit tidak melakukan)
        4. PENTING: Jika seorang siswa tidak disebutkan dalam suatu aktivitas, HARUS diberikan status null (tidak melakukan).
        5. Jika ada indikasi pengecualian seperti "Semua anak kecuali [nama]", maka:
           - Siswa yang dikecualikan diberi status sesuai konteks
           - Semua siswa lain diberi status sebaliknya
        6. Tambahkan kolom "Curhatan" yang menggambarkan kesan atau komentar guru.
        7. Format output harus dalam bentuk CSV dengan kolom:
           - Nama Lengkap
           - Nama Panggilan
           - Aktivitas (status kemandirian)
           - Curhatan
        9. Output adalah berupa CSV saja

            Contoh Versi 1:

            **Contoh Input:**
            Nama Murid: FullnameA (NicknameA), FullnameB (NicknameB), FullnameC (NicknameC)
            curhatan Guru: "Semua anak upacara dengan disiplin, lalu mereka memotong kuku sendiri kecuali NicknameB yang harus digunting kukunya oleh gurunya."

            **Contoh Output:**
            ```csv
            Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
            FullnameA,NicknameA,"Upacara (true)|Memotong kuku (true)", "NicknameA menunjukkan kedisiplinan dalam upacara."
            FullnameB,NicknameB,"Upacara (true)|Memotong kuku (false)", "NicknameB perlu banyak latih diri agar bisa mandiri."
            FullnameC,NicknameC,"Upacara (true)|Memotong kuku (true)", "NicknameC disiplin saat upacara dan bisa melakukannya sendiri."
            ```

            Contoh versi 2:

            **Contoh Input:**
            Nama Murid: FullnameA (NicknameA), FullnameB (NicknameB), FullnameC (NicknameC)
            curhatan Guru: "Semua anak kecuali NicknameB upacara dengan disiplin."

            **Contoh Output:**
            ```csv
            Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
            FullnameA,NicknameA,"Upacara (true)", "NicknameA menunjukkan kedisiplinan dalam upacara."
            FullnameB,NicknameB,"Upacara (false)", "NicknameB perlu banyak latih diri agar bisa disiplin."
            FullnameC,NicknameC,"Upacara (true)", "NicknameC disiplin saat upacara dan bisa melakukannya sendiri."
            ```

            Contoh versi 3:

            **Contoh Input:**
            Nama Murid: FullnameA (NicknameA), FullnameB (NicknameB), FullnameC (NicknameC)
            curhatan Guru: "NicknameA Upacara dengan baik. Semua anak bernyanyi dengan sangat baik dan merdu"

            **Contoh Output:**
            ```csv
            Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
            FullnameA,NicknameA,"Upacara (true)|Menyanyi (true)", "NicknameA menunjukkan kedisiplinan dalam upacara dan menyanyi sangat merdu."
            FullnameB,NicknameB,"Upacara (null)|Menyanyi (true)", "NicknameB menyanyi sangat merdu."
            FullnameC,NicknameC,"Upacara (null)|Menyanyi (true)", "NicknameC Menyanyi Sangat Merdu."
            ```

            Contoh Versi 4:

            **Contoh Input:**
            Nama Murid: FullnameA (NicknameA), FullnameB (NicknameB), FullnameC (NicknameC)
            curhatan Guru: "NicknameA Upacara dengan baik dan NicknameC bernyanyi dengan butuh bimbingan"

            **Contoh Output:**
            ```csv
            Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
            FullnameA,NicknameA,"Upacara (true)|Menyanyi (null)", "NicknameA menunjukkan kedisiplinan dalam upacara."
            FullnameB,NicknameB,"Upacara (null)|Menyanyi (null)", "Tidak ada informasi satupun."
            FullnameC,NicknameC,"Upacara (null)|Menyanyi (false)", "Tidak ada informasi satupun."
            ```

            Contoh Versi 5:

            **Contoh Input:**
            Nama Murid: FullnameA (NicknameA), FullnameB (NicknameB), FullnameC (NicknameC)
            curhatan Guru: "NicknameA Upacara dengan baik"

            **Contoh Output:**
            ```csv
            Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
            FullnameA,NicknameA,"Upacara (true)", "NicknameA menunjukkan kedisiplinan dalam upacara."
            FullnameB,NicknameB,"Upacara (null)", "Tidak ada informasi satupun."
            FullnameC,NicknameC,"Upacara (null)", "Tidak ada informasi satupun."
            ```

            Contoh Versi 6:
            **Contoh Input:**
            Nama Murid: FullnameA (NicknameA), FullnameB (NicknameB), FullnameC (NicknameC)
            curhatan Guru: "woy gw mau curhat huhuhu semua anak kecuali NicknameB upacara dengan sangat hebatttt. Adapun NicknameC tadi senamnya memerlukan bantuan untuk gerakan khusus seperti tepuk tangan dalam senam"

            **Contoh Output:**
            ```csv
            Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian), Curhatan
            FullnameA,NicknameA,"Upacara (true)|Senam (null)", "NicknameA menunjukkan kedisiplinan dalam upacara, tapi tidak melakukan senam."
            FullnameB,NicknameB,"Upacara (false)|Senam (null)", "NicknameB membutuhkan bimbingan dalam upacara."
            FullnameC,NicknameC,"Upacara (true)|Senam (false)", "NicknameC Menunjukkan kedisplinan pada saat upacara dan membutuhkan bimbingan dalam senam seperti pada gerakan tepuk tangan dalam senam."
            ```

            **Contoh Input:**
            ```csv
            "NicknameA bermain balok dengan mandiri"
            
            
            **Contoh Output:**
            ```csv
            Nama Lengkap,Nama Panggilan,Aktivitas (status kemandirian),Curhatan
            FullnameA,NicknameA,"Bermain balok (true)","NicknameA bermain balok dengan mandiri"
            FullnameB,NicknameB,"Bermain balok (null)","Tidak ada informasi aktivitas"
            FullnameC,NicknameC,"Bermain balok (null)","Tidak ada informasi aktivitas"
        
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
                            let statusString = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ")", with: "")
                                .lowercased()
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            // Perbaikan penanganan status
                            var isIndependent: Bool?
                            switch statusString {
                            case "true":
                                isIndependent = true
                            case "false":
                                isIndependent = false
                            case "null", "nil", "":
                                isIndependent = nil
                            default:
                                // Jika tidak ada informasi atau tidak melakukan, set nil
                                isIndependent = nil
                            }
                            
                            // Tambahkan pengecekan untuk "Tidak ada informasi aktivitas"
                            if curhatan.contains("Tidak ada informasi aktivitas") {
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
                }
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
