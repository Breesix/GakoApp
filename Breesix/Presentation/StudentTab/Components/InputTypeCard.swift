//
//  InputTypeCard.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct InputTypeCard: View {
    let inputType: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(width: 170, height: 208)
                .foregroundStyle(.gray.opacity(0.5))
                .clipShape(.rect(cornerRadius: 12))
            
            Text(inputType)
                .font(.headline)
                .foregroundStyle(.black)
        }
    }
}


#Preview {
    InputTypeCard(inputType: "Suara")
}
