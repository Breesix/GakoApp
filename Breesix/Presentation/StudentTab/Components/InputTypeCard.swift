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
                .frame(maxWidth: 170, maxHeight: 208)
                .foregroundStyle(.monochrome9002)
                .clipShape(.rect(cornerRadius: 12))
            
            Text(inputType)
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}


#Preview {
    InputTypeCard(inputType: "[Suara]")
}
