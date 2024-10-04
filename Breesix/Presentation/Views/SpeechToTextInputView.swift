//
//  SpeechToTextInputView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/10/24.
//

import SwiftUI

struct SpeechToTextInputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @State private var speechText = ""
    @State private var isRecording = false
    @State private var recognitionError: String?


    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//#Preview {
//    SpeechToTextInputView()
//}
