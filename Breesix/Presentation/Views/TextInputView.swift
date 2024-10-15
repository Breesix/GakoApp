//
//  TextInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct TextInputView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var textInput: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            
            VStack {
                Text("Curhat dengan ketikan")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(radius: 2)
                        .frame(maxWidth: .infinity, maxHeight: 250)

                    TextEditor(text: $textInput)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(10)
                }
                .padding(.bottom, 16)
                
                Button {
                    print("Submit clicked")
                } label: {
                    Text("Submit")
                        .frame(maxWidth: .infinity, maxHeight: 40)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                ProTipsCard()
                
                Spacer()
                
                Button {
                    showAlert = true
                } label: {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Batalkan")
                    }
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.red.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding()
        }
        .safeAreaPadding()
        .navigationBarBackButtonHidden(true)
        .alert(isPresented :$showAlert) {
            Alert(
                title: Text("Batalkan Dokumentasi?"),
                message: Text("Semua teks yang anda masukkan akan dihapus secara permanen"),
                primaryButton: .destructive(Text("Ya")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("Tidak"))
            )
        }
    }
}

#Preview {
    TextInputView()
}
