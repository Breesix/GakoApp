//
//  ReflectionInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

import OpenAI

struct ReflectionInputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Binding var isShowingPreview: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let openAI = OpenAI(apiToken: "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")
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $reflection)
                    .padding()
                    .border(Color.gray, width: 1)
                
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("Next") {
                    processReflection()
                }
                .padding()
                .disabled(reflection.isEmpty || isLoading)
            }
            .navigationTitle("Curhat Manual")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func processReflection() {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                
                await viewModel.loadStudents()
                
                let studentNames = viewModel.students.map { $0.fullname }.joined(separator: ", ")
                
                if viewModel.students.isEmpty {
                    throw NSError(domain: "ReflectionInputView", code: 1, userInfo: [NSLocalizedDescriptionKey: "Tidak ada data murid tersedia."])
                }
                
                let prompt = """
                Data Murid: \(studentNames)

                Pertanyaan Pemandu: Bagaimana aktivitas umum dan toilet training yang dilakukan oleh murid-murid hari ini?

                Refleksi Guru: \(reflection)

                Tugas:
                1. Analisis refleksi guru dengan cermat.
                2. Untuk setiap murid yang disebutkan dalam Data Murid:
                   a. Tentukan aktivitas umum murid
                   b. Tentukan catatan toilet training
                   c. Tentukan status toilet training (true/false)
                3. Jika informasi spesifik tidak tersedia, gunakan imajinasi kreatif untuk mengisi detail yang masuk akal berdasarkan konteks umum aktivitas anak-anak.
                4. Susun informasi dalam format CSV dengan kolom: Name,GeneralActivity,ToiletTraining,ToiletTrainingStatus

                Format Output:
                Name,GeneralActivity,ToiletTraining,ToiletTrainingStatus
                [NAMA_MURID_1],"[AKTIVITAS_UMUM]","[CATATAN_TOILET_TRAINING]",[STATUS_TOILET_TRAINING]
                [NAMA_MURID_2],"[AKTIVITAS_UMUM]","[CATATAN_TOILET_TRAINING]",[STATUS_TOILET_TRAINING]

                Contoh Output yang Diharapkan:
                Name,GeneralActivity,ToiletTraining,ToiletTrainingStatus
                Nakal putri aulia,"Bermain puzzle dan mewarnai","Berhasil ke toilet 2 kali, masih perlu diingatkan",true
                Jojo Mulyono nep,"Membaca buku cerita dan bermain balok","Menggunakan popok, belum menunjukkan minat ke toilet",false

                Petunjuk Tambahan:
                - Gunakan imajinasi kreatif untuk mengisi detail yang masuk akal jika informasi spesifik tidak tersedia
                - Pastikan setiap murid memiliki catatan yang unik dan relevan
                - Jangan gunakan "Tidak ada data" kecuali benar-benar tidak ada konteks sama sekali
                """
                
                print("Prompt: \(prompt)")
                
                let query = ChatQuery(messages: [.init(role: .user, content: prompt)!], model: .gpt4)
                
                let result = try await openAI.chats(query: query)
                print("API Response: \(result)")
                
                if let csvString = result.choices.first?.message.content?.string {
                    if csvString.contains("Tidak ada data") {
                        throw NSError(domain: "ReflectionInputView", code: 5, userInfo: [NSLocalizedDescriptionKey: "Refleksi tidak mengandung informasi yang cukup. Mohon berikan detail lebih lanjut tentang aktivitas murid."])
                    } else {
                        await parseAndCreateNotes(csvString: csvString)
                    }
                } else {
                    throw NSError(domain: "ReflectionInputView", code: 2, userInfo: [NSLocalizedDescriptionKey: "Tidak ada konten dalam respons."])
                }
                
                await MainActor.run {
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                    isShowingPreview = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    print("Error in processReflection: \(error)")
                }
            }
        }
    }

    private func parseAndCreateNotes(csvString: String) async {
        let rows = csvString.components(separatedBy: .newlines)
        
        for row in rows.dropFirst() where !row.isEmpty {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 4 {
                let name = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let generalActivity = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let toiletTraining = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let toiletTrainingStatus = columns[3].lowercased() == "true"
                
                if let student = viewModel.students.first(where: { $0.fullname == name }) {
                    let newNote = Note(
                        generalActivity: generalActivity,
                        toiletTraining: toiletTraining,
                        toiletTrainingStatus: toiletTrainingStatus,
                        student: student
                    )
                    
                    await viewModel.addNote(newNote, for: student)
                }
            }
        }
    }
    
    private func parseAndCreateNotes(csvString: String) {
        let rows = csvString.components(separatedBy: .newlines)
        
        for row in rows.dropFirst() where !row.isEmpty {
            let columns = row.components(separatedBy: ",")
            if columns.count >= 4 {
                let name = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let generalActivity = columns[1].trimmingCharacters(in: .init(charactersIn: "\""))
                let toiletTraining = columns[2].trimmingCharacters(in: .init(charactersIn: "\""))
                let toiletTrainingStatus = columns[3].lowercased() == "true"
                
                if let student = viewModel.students.first(where: { $0.fullname == name }) {
                    let newNote = Note(
                        generalActivity: generalActivity,
                        toiletTraining: toiletTraining,
                        toiletTrainingStatus: toiletTrainingStatus,
                        student: student
                    )
                    
                    Task {
                        await viewModel.addNote(newNote, for: student)
                    }
                }
            }
        }
        
        presentationMode.wrappedValue.dismiss()
        isShowingPreview = true
    }
}
