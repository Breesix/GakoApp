//
//  LlamaService.swift
//  Breesix
//
//  Created by Rangga Biner on 29/10/24.
//

import Foundation
import SwiftData

class LlamaService {
    private let apiKey: String
    private let baseURL = "https://integrate.api.nvidia.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
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
        3.  tolong bedakan menjadi 2 tipe aktivitas: aktivitas tipe A, yaitu aktivitas-aktivitas yang umumnya menjadi sebuah materi aktivitas pembelajaran harian di sebuah sekolah SLB untuk anak-anak autisme (kegiatan-kegiatan seputar latihan motorik, wicara, rohani, dsb); aktivitas tipe  B, yaitu observasi perilaku non-pelajaran atau perilaku tak terduga, yaitu  terkait hal-hal yang diluar pembelajaran formal, misalnya hal-hal interpersonal, intrapersonal, sosial, sikap dengan teman sekelas dan sebagainya (mis: dia berantem, dia tantrum, dia jatuh, dsb).
        4. Tentukan untuk setiap aktivitas yang termasuk ke tipe aktivitas A, apakah siswa melakukannya secara "mandiri" atau "dibimbing”. Jika Mandiri = True, Jika Dibimbing = False.
        Jika ada indikasi pengecualian, maka bukan berarti murid tersebut tidak melakukan aktivitas tersebut. Misal “Semua anak Bermain Balok dengan hebat kecuali Rangga“ atau “Semua anak kecuali Rangga Bermain Balok dengan hebat” maka dalam kasus ini status kemandirian Rangga adalah “Bermain Balok (false)”
        5. Jika suatu aktivitas yang termasuk ke tipe aktivitas A tidak disebutkan untuk siswa tertentu, isikan status kemandirian aktivitas tersebut dengan "null".
        6. Tambahkan kolom "Curhatan" yang menggambarkan kesan atau komentar guru tentang masing-masing siswa terkait kegiatan yang dilakukan, baik aktivitas tipe A maupun tipe B.
        7. Pastikan hanya mencantumkan aktivitas yang disebutkan dalam curhatan tanpa menambahkan aktivitas lain.
        8. Format output harus dalam bentuk CSV dengan kolom sesuai dengan Input User:
        - Nama Lengkap
        - Nama Panggilan
        - Aktivitas  (status kemandirian)
        - Curhatan
        9. yang dimasukkan ke kolom Aktivitas (status kemandirian) hanyalah aktivitas tipe A saja
        10. yang dimasukkan ke kolom curhattan adalah sesuai instruksi nomor 6.
        11. Output yang anda berikan berupa CSV saja, tidak perlu penjelasan atau catatan tambahan terkait hasil yang anda berikan.

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
        Nama Murid: Rangga Hadi (Rangga), Joko (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “Rangga Upacara dengan baik dan Samuel bernyanyi dengan butuh bimbingan”

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas pembelajaran (status kemandirian), Curhatan
        Rangga Hadi,Rangga,"Upacara (true)|Menyanyi (null)”, "Rangga menunjukkan kedisiplinan dalam upacara.”
        Joko Sambodo,JokSa,"Upacara (null)|Menyanyi (null)”, "Tidak ada informasi satupun."
        Samuel Suharto,Samuel,”Upacara (null)|Menyanyi (false)”, “Tidak ada informasi satupun.”
        ```

        Contoh Versi 5:

        **Contoh Input:**
        Nama Murid: Rangga Hadi (Rangga), Joko (JokSa), Samuel Suharto (Samuel)
        curhatan Guru: “Rangga Upacara dengan baik”

        **Contoh Output:**
        ```csv
        Nama Lengkap,Nama Panggilan,Aktivitas pembelajaran (status kemandirian), Curhatan
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

        """

        let userInput = """
        INPUT USER:
        Input User yang harus anda analisis adalah:

        Data Murid: \(studentInfo)

        Curhatan Guru: \(reflection)
        
        Hasilkan CSV Output only sesuai dengan instruksi yang telah diberikan
        """

        let fullPrompt = botPrompt + "\n\n" + userInput
        
        let requestBody: [String: Any] = [
            "model": "meta/llama-3.1-405b-instruct",
            "messages": [
                ["role": "user", "content": fullPrompt]
            ],
            "temperature": 0.5,
            "max_tokens": 1024,
            "top_p": 1
        ]
        
        print(fullPrompt)
        
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
        
        guard let csvString = result.choices.first?.message.content else {
            throw ProcessingError.noContent
        }
        
        if csvString.contains("Tidak ada informasi") && !csvString.contains(",") {
            throw ProcessingError.insufficientInformation
        }
        
        return csvString
    }
}

struct LlamaResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}
