//
//  CustomSearchBar.swift
//  Gako
//
//  Created by Rangga Biner on 01/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom search bar component that includes text input and voice recognition functionality
//  Usage: Use this component to provide search functionality with both text and voice input options
//

import SwiftUI
import Speech

struct CustomSearchBar: View {
    // MARK: - Constants
    private let textColor = UIConstants.CustomSearchBar.textColor
    private let placeholderColor = UIConstants.CustomSearchBar.placeholderColor
    private let backgroundColor = UIConstants.CustomSearchBar.backgroundColor
    private let iconColor = UIConstants.CustomSearchBar.iconColor
    private let recordingIconColor = UIConstants.CustomSearchBar.recordingIconColor
    private let cornerRadius = UIConstants.CustomSearchBar.cornerRadius
    private let iconPadding = UIConstants.CustomSearchBar.iconPadding
    private let textPadding = UIConstants.CustomSearchBar.textPadding
    private let verticalPadding = UIConstants.CustomSearchBar.verticalPadding
    private let placeholder = UIConstants.CustomSearchBar.placeholder
    private let searchIconBar = UIConstants.CustomSearchBar.searchIcon
    private let micIcon = UIConstants.CustomSearchBar.micIcon
    private let micStopIcon = UIConstants.CustomSearchBar.micStopIcon
    private let clearIcon = UIConstants.CustomSearchBar.clearIcon
    
    // MARK: - Properties
    @Binding var text: String
    @State var isEditing = false
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State var isRecording = false
    
    // MARK: - Body
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
    
    // MARK: - Subview
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
    
    // MARK: - Subview
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
    
    // MARK: - Subview
    private var searchTextField: some View {
        TextField("", text: $text)
            .foregroundStyle(textColor)
            .padding(.horizontal, textPadding)
            .padding(.vertical, verticalPadding)
    }
    
    // MARK: - Subview
    private var searchOverlay: some View {
        HStack {
            searchIcon
            rightIcon
        }
    }
    
    // MARK: - Subview
    private var searchIcon: some View {
        Image(systemName: searchIconBar)
            .foregroundStyle(iconColor)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, iconPadding)
    }
    
    // MARK: - Subview
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
    
    // MARK: - Subview
    private var stopRecordingButton: some View {
        Button(action: stopRecording) {
            Image(systemName: micStopIcon)
                .foregroundStyle(recordingIconColor)
                .padding(.trailing, iconPadding)
        }
    }
    
    // MARK: - Subview
    private var startRecordingButton: some View {
        Button(action: startRecording) {
            Image(systemName: micIcon)
                .foregroundStyle(iconColor)
                .padding(.trailing, iconPadding)
        }
    }
    
    // MARK: - Subview
    private var clearButton: some View {
        Button(action: clearText) {
            Image(systemName: clearIcon)
                .foregroundStyle(iconColor)
                .padding(.trailing, iconPadding)
        }
    }
    
    // MARK: - Subview
    private var cancelButton: some View {
        Button(action: cancelSearch) {}
            .padding(.trailing, iconPadding)
            .transition(.move(edge: .trailing))
    }
}

// MARK: - Preview
#Preview {
    CustomSearchBar(text: .constant(""))
}
