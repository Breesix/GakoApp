//
//  ProTipsCard.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct ProTipsCard: View {
    var body: some View {
            VStack() {
                Text("PRO TIPS:")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .padding(.bottom, 2)
                
                Text("Tidak perlu menyebutkan nama murid satu-persatu, cukup katakan “Semua murid...” atau “Semua murid kecuali...”")
                    .font(.subheadline)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        }
}

#Preview {
    ProTipsCard()
}
