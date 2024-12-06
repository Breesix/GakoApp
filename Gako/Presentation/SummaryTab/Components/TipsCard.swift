//
//  TipsCard.swift
//  Gako
//
//  Created by Rangga Biner on 24/10/24.
//
//  Description: A card view that displays tips for the daily report section.
//  Usage: Use this view to display tips in the daily report section.   

import SwiftUI

struct TipsCard: View {
    var body: some View {
        VStack {
            Image("Expressions")
                .resizable()
                .scaledToFit()
                .frame(width: 53)
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
        .foregroundStyle(.green300)
        .cornerRadius(12)
    }
}

#Preview {
    TipsCard()
}

