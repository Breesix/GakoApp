//
//  InputTypeView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

enum InputTypeUser {
    case voice
    case text
}

struct InputTypeView: View {
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (InputTypeUser) -> Void
    
    var body: some View {
        VStack (spacing: 0) {
            Spacer()

            Text("Pilih Metode Input")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.labelPrimary)
            
            Spacer()
            
            HStack (spacing: 0) {
                Button(action: {
                    onSelect(.voice)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("voice-input-card")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 208)
                }
                
                Spacer()
                
                Button(action: {
                    onSelect(.text)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("text-input-card")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 208)
                }
            }
            .foregroundStyle(.black)
            
            Spacer()
            
            Button("Batalkan") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundStyle(.destructiveOnCardLabel)
            .font(.body)
            .fontWeight(.semibold)
            
            Spacer()

        }
        .background(.white)
        .padding(.horizontal, 16)
    }
}

#Preview {
    InputTypeView { inputType in
        print("Selected input type: \(inputType)")
    }
}
