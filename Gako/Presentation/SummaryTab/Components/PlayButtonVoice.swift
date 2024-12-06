//
//  PlayButtonVoice.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//
//  Description: A button view for playing the voice recording in the input view.
//  Usage: Use this view to play the voice recording in the input view.

import SwiftUI

struct PlayButtonVoice: View {
    var body: some View {
        VStack{
            Circle()
                .overlay{
                    Image(systemName: "play.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 29)
                        .foregroundColor(Color.black)
                }
                .foregroundColor(Color.yellow600)
                .frame(width: 84, alignment: .center)
            
            
        }
    }
}

#Preview {
    PlayButtonVoice()
}
