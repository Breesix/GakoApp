//
//  SpeechRecognizer.swift
//  Breesix
//
//  Created by Kevin Fairuz on 02/10/24.
//

import Foundation
import AVFoundation
import Speech

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
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Optimasi konfigurasi audio untuk speech recognition
            try audioSession.setCategory(.playAndRecord,
                                         mode: .spokenAudio, // Gunakan mode spokenAudio
                                         options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setPreferredIOBufferDuration(0.005) // Kurangi latency
            try audioSession.setPreferredSampleRate(44100) // Gunakan sample rate yang optimal
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
            return
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        
        // Konfigurasi recognition request untuk akurasi lebih baik
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .dictation
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = false // Gunakan server-side recognition untuk akurasi lebih baik
        }
        
        // Tambahkan audio tap dengan buffer size yang lebih besar
        inputNode.installTap(onBus: 0,
                             bufferSize: 4096, // Tingkatkan buffer size
                             format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine failed to start: \(error.localizedDescription)")
        }
        
        // Implementasi recognition task dengan penanganan hasil yang lebih baik
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            var isFinal = false
            
            if let result = result {
                DispatchQueue.main.async {
                    let newTranscript = self.processTranscript(result.bestTranscription.formattedString)
                    
                    if newTranscript != self.currentTranscript {
                        self.currentTranscript = newTranscript
                        
                        if !self.previousTranscript.isEmpty {
                            // Gabungkan dengan mempertahankan editan sebelumnya
                            self.transcript = self.previousTranscript + " " + self.currentTranscript
                        } else {
                            self.transcript = self.currentTranscript
                        }
                    }
                    
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.stopTranscribing()
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
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        
        DispatchQueue.main.async {
            self.isRecognitionInProgress = false
            // Simpan transcript terakhir sebelum berhenti
            self.previousTranscript = self.transcript
        }
    }
    
    func pauseTranscribing() {
        audioEngine.pause()
        recognitionRequest?.endAudio()
        
        DispatchQueue.main.async {
            self.isRecognitionInProgress = false
        }
    }
    
    func resumeTranscribing() {
        // Buat request baru untuk melanjutkan recognition
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        do {
            try audioEngine.start()
            
            DispatchQueue.main.async {
                self.isRecognitionInProgress = true
            }
            
            // Setup recognition task baru
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
                var isFinal = false
                
                if let result = result {
                    DispatchQueue.main.async {
                        // Proses transcript baru
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
                    isFinal = result.isFinal
                }
                
                if error != nil || isFinal {
                    self.stopTranscribing()
                }
            }
        } catch {
            print("Failed to resume audio engine: \(error.localizedDescription)")
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
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}




