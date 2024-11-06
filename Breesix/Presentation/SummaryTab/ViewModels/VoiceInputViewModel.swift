//
//  VoiceInputViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//

import SwiftUI
import Mixpanel
import Speech

class VoiceInputViewModel: InputViewModel {
    // Add new @Published properties
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var reflection: String = ""
    @Published var editedText: String = ""
    
    
    let speechRecognizer = SpeechRecognizer()
    
    override init(analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared) {
        super.init(analytics: analytics)
        requestSpeechAuthorization()
    }
    
  
    
    func requestSpeechAuthorization() {
            SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        self.analytics.trackEvent("Speech Recognition Authorized", properties: nil)
                    case .denied:
                        self.analytics.trackEvent("Speech Recognition Denied", properties: nil)
                    case .restricted:
                        self.analytics.trackEvent("Speech Recognition Restricted", properties: nil)
                    case .notDetermined:
                        self.analytics.trackEvent("Speech Recognition Not Determined", properties: nil)
                    @unknown default:
                        self.analytics.trackEvent("Speech Recognition Unknown Status", properties: nil)
                    }
                }
            }
        }
    
    // Create computed properties that sync with parent
    @Published private var _isLoading = false
    override var isLoading: Bool {
        get { _isLoading }
        set {
            DispatchQueue.main.async { [weak self] in
                self?._isLoading = newValue
            }
        }
    }

    
    @Published private var _errorMessage: String?
    override var errorMessage: String? {
        get { _errorMessage }
        set {
            DispatchQueue.main.async { [weak self] in
                self?._errorMessage = newValue
            }
        }
    }
    
    private func updateState(_ action: @escaping () -> Void) {
        DispatchQueue.main.async {
            action()
        }
    }

    
    func startRecording() {
        isRecording = true
        isPaused = false
        inputStartTime = Date()
        analytics.trackInputStarted(type: .voice, date: Date())
        speechRecognizer.startTranscribing()
    }
    
    func stopRecording(text: String) {
        isRecording = false
        speechRecognizer.stopTranscribing()
        analytics.trackInputCompleted(
            type: .voice,
            success: true,
            duration: Date().timeIntervalSince(inputStartTime ?? Date()),
            textLength: text.count
        )
    }
    
    func pauseRecording() {
        isPaused = true
        speechRecognizer.pauseTranscribing()
        analytics.trackInputCancelled(type: .voice)
    }
    
    func resumeRecording() {
        isPaused = false
        speechRecognizer.resumeTranscribing()
        analytics.trackInputStarted(type: .voice, date: Date())
    }
    
    func clearText() {
        reflection = ""
        editedText = ""
        speechRecognizer.transcript = ""
        isRecording = false
        isPaused = false
    }
}





