//
//  SpeechRecognizer.swift
//  Breesix
//
//  Created by Kevin Fairuz on 02/10/24.
//

import Foundation
import AVFoundation
import Speech
import AVFAudio

class SpeechRecognizer: ObservableObject {
    private let speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var previousTranscript = ""
    private var currentTranscript = ""
    private var lastProcessedText = ""
    @Published var transcript = ""
    @Published var isRecognitionInProgress = false
    @Published var hasSpeechPermission = false
    @Published var hasMicPermission = false
    
    init(language: String = "id-ID") {
        // Pastikan locale menggunakan id-ID untuk Bahasa Indonesia
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))!
        
        // Tambahkan konfigurasi tambahan untuk meningkatkan akurasi
        speechRecognizer.defaultTaskHint = .dictation // Menggunakan mode dikte
        speechRecognizer.supportsOnDeviceRecognition = true // Gunakan on-device recognition jika tersedia
    }
    
    private func setupAudioSessionAndEngine() {
        // Reset recognition task jika ada
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Gunakan konfigurasi yang lebih aman
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            // Gunakan format yang didukung device
            let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: audioSession.sampleRate,
                                              channels: 1)
            
            guard let format = recordingFormat else {
                print("Failed to create audio format")
                return
            }
            
            // Pastikan input node dan format valid
            inputNode.removeTap(onBus: 0) // Hapus tap yang ada sebelum menambah yang baru
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            
            recognitionRequest.shouldReportPartialResults = true
            
            // Install tap dengan error handling
            inputNode.installTap(onBus: 0,
                               bufferSize: 1024,
                               format: format) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            // Start audio engine dengan error handling
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            
        } catch {
            print("Audio session/engine setup failed: \(error.localizedDescription)")
            stopTranscribing() // Clean up jika terjadi error
            return
        }
        
        // Setup recognition task
        setupRecognitionTask()
    }
    
    private func setupRecognitionTask() {
        guard let recognitionRequest = recognitionRequest else { return }
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Recognition task error: \(error.localizedDescription)")
                self.stopTranscribing()
                return
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    let newTranscript = self.processTranscript(result.bestTranscription.formattedString)
                    
                    if newTranscript != self.currentTranscript {
                        self.currentTranscript = newTranscript
                        if !self.previousTranscript.isEmpty {
                            self.transcript = self.previousTranscript + " " + self.currentTranscript
                        } else {
                            self.transcript = self.currentTranscript
                        }
                    }
                }
                
                if result.isFinal {
                    self.stopTranscribing()
                }
            }
        }
    }
    
    func startTranscribing() {
        currentTranscript = ""
        transcript = previousTranscript // Ini penting untuk mempertahankan teks sebelumnya
        
        Task {
            let speechPermissionGranted = await SFSpeechRecognizer.hasAuthorizationToRecognize()
            let micPermissionGranted = await AVAudioSession.sharedInstance().hasPermissionToRecord()
            
            DispatchQueue.main.async {
                self.hasSpeechPermission = speechPermissionGranted
                self.hasMicPermission = micPermissionGranted
                
                if speechPermissionGranted && micPermissionGranted {
                    self.isRecognitionInProgress = true
                    self.setupAudioSessionAndEngine()
                } else {
                    print("Permission denied. Speech: \(speechPermissionGranted), Mic: \(micPermissionGranted)")
                }
            }
        }
    }
    
    
    // Tambahkan fungsi untuk memproses transcript
    private func processTranscript(_ text: String) -> String {
        // Jika teks sama persis dengan yang terakhir diproses, abaikan
        if text == lastProcessedText {
            return currentTranscript
        }
        
        var processed = text
        
        // Bersihkan pengulangan kata
        processed = cleanRepeatedWords(processed)
        
        // Kapitalisasi awal kalimat
        processed = processed.capitalizingFirstLetter()
        
        // Perbaiki spasi ganda
        processed = processed.replacingOccurrences(of: "\\s+",
                                                   with: " ",
                                                   options: .regularExpression)
        
        // Tambahkan tanda baca hanya di akhir kalimat yang selesai
        if !processed.isEmpty {
            let sentences = processed.components(separatedBy: " ")
            let lastWord = sentences.last!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Cek apakah ini akhir kalimat berdasarkan konteks
            let isEndOfSentence = lastWord.lowercased().contains("selesai") ||
                                 lastWord.lowercased().contains("akhirnya") ||
                                 lastWord.lowercased().contains("terima kasih") ||
                                 lastWord.hasSuffix(".") ||
                                 lastWord.hasSuffix("?") ||
                                 lastWord.hasSuffix("!")
            
            // Hanya tambahkan titik jika ini akhir kalimat dan belum ada tanda baca
            if isEndOfSentence && ![".", "?", "!"].contains(String(lastWord.last!)) {
                processed += "."
            }
        }
        
        lastProcessedText = text // Update teks terakhir yang diproses
        return processed.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func cleanRepeatedWords(_ text: String) -> String {
        let words = text.components(separatedBy: " ")
        var cleanedWords: [String] = []
        var lastWord = ""
        
        for word in words {
            let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            // Cek jika kata saat ini berbeda dengan kata sebelumnya
            if cleanWord != lastWord {
                cleanedWords.append(word)
                lastWord = cleanWord
            }
        }
        
        return cleanedWords.joined(separator: " ")
    }
    
    
    
    func stopTranscribing() {
        // Pastikan semua resources dibersihkan dengan benar
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
        
        DispatchQueue.main.async {
            self.isRecognitionInProgress = false
            self.previousTranscript = self.transcript
        }
    }
    
    func pauseTranscribing() {
       
        if audioEngine.isRunning {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        
        DispatchQueue.main.async {
            self.isRecognitionInProgress = false
        }
    }
    
    func resumeTranscribing() {
        // Pastikan audio engine tidak sedang running
        guard !audioEngine.isRunning else { return }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Buat request baru
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            // Pastikan tidak ada tap yang aktif sebelum memasang tap baru
            inputNode.removeTap(onBus: 0)
            
            // Install tap baru
            inputNode.installTap(onBus: 0,
                               bufferSize: 4096,
                               format: recordingFormat) { (buffer, when) in
                self.recognitionRequest?.append(buffer)
            }
            
            // Start audio engine
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isRecognitionInProgress = true
            }
            
            // Setup recognition task baru
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    DispatchQueue.main.async {
                        let newTranscript = self.processTranscript(result.bestTranscription.formattedString)
                        
                        if newTranscript != self.currentTranscript {
                            self.currentTranscript = newTranscript
                            if !self.previousTranscript.isEmpty {
                                self.transcript = self.previousTranscript + " " + self.currentTranscript
                            } else {
                                self.transcript = self.currentTranscript
                            }
                        }
                    }
                }
                
                if error != nil || result?.isFinal == true {
                    self.stopTranscribing()
                }
            }
            
        } catch {
            print("Failed to resume audio engine: \(error.localizedDescription)")
            stopTranscribing()
        }
    }
    
}

// Extension untuk membantu pemrosesan teks
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

@available(macOS 10.15, *)
extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        if #available(iOS 17.0, *) {
            return await withCheckedContinuation { continuation in
                AVAudioApplication.requestRecordPermission { authorized in
                    continuation.resume(returning: authorized)
                }
            }
        } else {
            return await withCheckedContinuation { continuation in
                requestRecordPermission { authorized in
                    continuation.resume(returning: authorized)
                }
            }
        }
    }
}
