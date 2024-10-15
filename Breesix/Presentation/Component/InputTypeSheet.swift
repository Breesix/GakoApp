//
//  InputTypeSheet.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

enum InputTypeUser {
    case voice
    case text

}

struct InputTypeSheet: View {
    @State private var selectedInputType: InputTypeUser?
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (InputTypeUser) -> Void

    var body: some View {
        VStack {
            if let inputType = selectedInputType {
                switch inputType {
                case .voice:
                    VoiceInputView()
                case .text:
                    TextInputView()
                }
            } else {
                VStack {
                    Text("Pilih Metode Input")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.bottom, 24)

                    HStack {
                        Button(action: {
                            onSelect(.voice) 
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            InputTypeCard(inputType: "[Suara]")
                        }
                        .padding(.trailing, 20)

                        Button(action: {
                            onSelect(.text)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            InputTypeCard(inputType: "[Teks]")
                        }
                    }
                    .padding(.bottom, 29)

                    Button("Batalkan") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
