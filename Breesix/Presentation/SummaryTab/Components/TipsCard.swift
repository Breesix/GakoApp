//
//  TipsCard.swift
//  Breesix
//
//  Created by Rangga Biner on 24/10/24.
//

import SwiftUI

struct TipsCard: View {
    var body: some View {
        VStack() {
            HStack {
                Image(systemName: "sparkles")
            Text("TIPS")
                .padding(.bottom, 2)
                Image(systemName: "sparkles")
            }
            .fontWeight(.heavy)
            .font(.body)
            
            Text("Tidak perlu menyebutkan nama murid satu-persatu, cukup katakan “Semua murid...” atau “Semua murid kecuali...”")
                .font(.footnote)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .foregroundStyle(.green300)
        .background(.bgMain)
        .cornerRadius(12)
    }
}

#Preview {
    TipsCard()
}
