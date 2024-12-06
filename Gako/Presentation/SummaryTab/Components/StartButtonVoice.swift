//
//  StartButtonVoice.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Description: A button view for starting the voice recording in the input view.
//  Usage: Use this view to start the voice recording in the input view.    

import SwiftUI

struct StartButtonVoice: View {
    var body: some View {
        VStack{
            Circle()
                .overlay{
                    Image(systemName: "mic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 29)
                        .foregroundColor(Color.black)
                }
                .foregroundColor(Color.yellow600)
                .frame(width: 84)
            
            
        }
    }
}

#Preview {
    StartButtonVoice()
}
