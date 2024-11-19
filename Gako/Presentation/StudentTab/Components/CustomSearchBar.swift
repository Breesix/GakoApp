//
//  CustomSearchBar.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI
import Speech

struct CustomSearchBar: View {
    // MARK: - Constants
    private let textColor = UIConstants.SearchBar.textColor
    private let placeholderColor = UIConstants.SearchBar.placeholderColor
    private let backgroundColor = UIConstants.SearchBar.backgroundColor
    private let iconColor = UIConstants.SearchBar.iconColor
    private let recordingIconColor = UIConstants.SearchBar.recordingIconColor
    
    private let cornerRadius = UIConstants.SearchBar.cornerRadius
    private let iconPadding = UIConstants.SearchBar.iconPadding
    private let textPadding = UIConstants.SearchBar.textPadding
    private let verticalPadding = UIConstants.SearchBar.verticalPadding
    
    private let placeholder = UIConstants.SearchBar.placeholder
    private let searchIconBar = UIConstants.SearchBar.searchIcon
    private let micIcon = UIConstants.SearchBar.micIcon
    private let micStopIcon = UIConstants.SearchBar.micStopIcon
    private let clearIcon = UIConstants.SearchBar.clearIcon
    
    // MARK: - Properties
    @Binding var text: String
    @State private var isEditing = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    var body: some View {
        HStack {
            searchField
            
            if isEditing {
                cancelButton
            }
        }
        .onReceive(speechRecognizer.$transcript) { newTranscript in
            self.text = newTranscript
        }
    }
    
    // MARK: - Subviews
    private var searchField: some View {
        ZStack(alignment: .leading) {
            searchPlaceholder
            searchTextField
        }
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .overlay(searchOverlay)
        .onTapGesture {
            withAnimation {
                self.isEditing = true
            }
            SpeechHelper.requestAuthorization { _ in }
        }
    }
    
    private var searchPlaceholder: some View {
        Group {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(placeholderColor)
                    .padding(.horizontal, textPadding)
                    .padding(.vertical, verticalPadding)
            }
        }
    }
    
    private var searchTextField: some View {
        TextField("", text: $text)
            .foregroundStyle(textColor)
            .padding(.horizontal, textPadding)
            .padding(.vertical, verticalPadding)
    }
    
    private var searchOverlay: some View {
        HStack {
            searchIcon
            rightIcon
        }
    }
    
    private var searchIcon: some View {
        Image(systemName: searchIconBar)
            .foregroundStyle(iconColor)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, iconPadding)
    }
    
    private var rightIcon: some View {
        Group {
            if isRecording {
                stopRecordingButton
            } else {
                if text.isEmpty {
                    startRecordingButton
                } else {
                    clearButton
                }
            }
        }
    }
    
    private var stopRecordingButton: some View {
        Button(action: stopRecording) {
            Image(systemName: micStopIcon)
                .foregroundStyle(recordingIconColor)
                .padding(.trailing, iconPadding)
        }
    }
    
    private var startRecordingButton: some View {
        Button(action: startRecording) {
            Image(systemName: micIcon)
                .foregroundStyle(iconColor)
                .padding(.trailing, iconPadding)
        }
    }
    
    private var clearButton: some View {
        Button(action: clearText) {
            Image(systemName: clearIcon)
                .foregroundStyle(iconColor)
                .padding(.trailing, iconPadding)
        }
    }
    
    private var cancelButton: some View {
        Button(action: cancelSearch) {}
        .padding(.trailing, iconPadding)
        .transition(.move(edge: .trailing))
    }
    
    // MARK: - Actions
    private func startRecording() {
        isRecording = true
        speechRecognizer.startTranscribing()
    }
    
    private func stopRecording() {
        isRecording = false
        speechRecognizer.stopTranscribing()
    }
    
    private func clearText() {
        self.text = ""
    }
    
    private func cancelSearch() {
        isEditing = false
        text = ""
        SpeechHelper.hideKeyboard()
    }
}

#Preview {
    CustomSearchBar(text: .constant(""))
}
