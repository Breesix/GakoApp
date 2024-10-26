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
    
    @Published var transcript = ""
    @Published var isRecognitionInProgress = false
    @Published var hasSpeechPermission = false
    @Published var hasMicPermission = false
    
    init(language: String = "id-ID") {
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))!
    }
    
    func startTranscribing() {
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
    
    private func setupAudioSessionAndEngine() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        if recordingFormat.sampleRate <= 0 {
            print("Invalid sample rate: \(recordingFormat.sampleRate)")
            return
        }

        print("Recording Format Sample Rate: \(recordingFormat.sampleRate), Channels: \(recordingFormat.channelCount)")

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest?.shouldReportPartialResults = true

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }

        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine failed to start: \(error.localizedDescription)")
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
            var isFinal = false

            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self.stopTranscribing()
            }
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        
        DispatchQueue.main.async {
            self.isRecognitionInProgress = false // Ensure this runs on the main thread
        }
    }

    func pauseTranscribing() {
        audioEngine.pause()
    }
        
    func resumeTranscribing() {
        do {
            try audioEngine.start()
        } catch {
            print("Failed to resume audio engine: \(error.localizedDescription)")
        }
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




