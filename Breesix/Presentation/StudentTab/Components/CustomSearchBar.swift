//
//  CustomSearchBar.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI
import Speech

struct CustomSearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    var body: some View {
            HStack {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Search")
                            .foregroundStyle(.labelSecondary)
                            .padding(.horizontal, 33)
                            .padding(.vertical, 7)
                    }
                    TextField("", text: $text)
                        .foregroundStyle(.buttonPrimaryLabel)
                        .padding(.horizontal, 33)
                        .padding(.vertical, 7)
                }
                .background(.fillTertiary)
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.labelSecondary)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isRecording {
                            Button(action: {
                                isRecording = false
                                speechRecognizer.stopTranscribing()
                            }) {
                                Image(systemName: "mic.fill.badge.xmark")
                                    .foregroundStyle(.red)
                                    .padding(.trailing, 8)
                            }
                        } else {
                            if text.isEmpty {
                                Button(action: {
                                    isRecording = true
                                    speechRecognizer.startTranscribing()
                                }) {
                                    Image(systemName: "mic.fill")
                                        .foregroundStyle(.labelSecondary)
                                        .padding(.trailing, 8)
                                }
                            } else {
                                Button(action: {
                                    self.text = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundStyle(.labelSecondary)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    }
                )
                .onTapGesture {
                    withAnimation {
                        self.isEditing = true
                    }
                    requestSpeechAuthorization()
                }

            }
            .onReceive(speechRecognizer.$transcript) { newTranscript in
                self.text = newTranscript
            }
        }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil,
                                      from: nil,
                                      for: nil)
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    print("Unknown status")
                }
            }
        }
    }
}

#Preview {
    CustomSearchBar(text: .constant(""))
}
