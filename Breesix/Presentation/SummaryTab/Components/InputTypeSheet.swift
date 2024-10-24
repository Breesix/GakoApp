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
    @ObservedObject var studentListViewModel: StudentTabViewModel
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (InputTypeUser) -> Void
    
    var body: some View {
        VStack {
            Spacer()

            Text("Pilih Metode Input")
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            HStack {
                Button(action: {
                    onSelect(.voice)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    InputTypeCard(inputType: "[Suara]")
                }
                
                Button(action: {
                    onSelect(.text)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    InputTypeCard(inputType: "[Teks]")
                }
            }
            .foregroundStyle(.black)
            
            Spacer()
            
            Button("Batalkan") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundStyle(.destructive)
            .font(.body)
            .fontWeight(.semibold)
            
            Spacer()

        }
        .padding(.horizontal, 16)
    }
}
