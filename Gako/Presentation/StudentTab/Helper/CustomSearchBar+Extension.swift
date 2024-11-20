//
//  CustomSearchBar+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension for CustomSearchBar that provides voice recording and search functionality
//  Usage: Use these methods to handle voice recording, text clearing, and search cancellation in the custom search bar
//

import Foundation

extension CustomSearchBar {
    // MARK: - Start Voice
    func startRecording() {
        isRecording = true
        speechRecognizer.startTranscribing()
    }
    
    // MARK: - Stop Voice
    func stopRecording() {
        isRecording = false
        speechRecognizer.stopTranscribing()
    }
    
    // MARK: - Clear Text
    func clearText() {
        self.text = ""
    }
    
    // MARK: - Cancel
    func cancelSearch() {
        isEditing = false
        text = ""
        SpeechHelper.hideKeyboard()
    }
}
