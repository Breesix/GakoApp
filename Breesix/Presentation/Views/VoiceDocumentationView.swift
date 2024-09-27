//
//  VoiceDocumentationView.swift
//  Breesix
//
//  Created by Rangga Biner on 27/09/24.
//

import SwiftUI

struct VoiceDocumentationView: View {
    var body: some View {
        VStack {
            Text("Ceritakan Keadaan kelas anda hari ini")
            VStack {
                HStack {
                    Text("Upacara?")
                    Spacer()
                    Text("Menari?")
                }
                HStack {
                    Text("Memasak?")
                    Spacer()
                    Text("Menjahit?")
                }
            }
            Spacer()
            Button(action: {
                print("miccc")
            }, label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: 90))
            })
        }
        .safeAreaPadding()
    }
}

#Preview {
    VoiceDocumentationView()
}
