//
//  TitleProgressCard.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//

import SwiftUI

struct TitleProgressCard: View {
    var title: String
    var subtitle: String

    var body: some View {
        VStack (alignment: .center, spacing: subtitle.isEmpty ? 0 : 8) {
            HStack {
                Image(systemName: "sparkles")
                Spacer()
                Text(title)
                Spacer()
                Image(systemName: "sparkles")
            }
            .fontWeight(.heavy)
            
            if !subtitle.isEmpty {
                Text(subtitle)
                    .fontWeight(.semibold)
                    .font(.caption)
                    .padding(.horizontal, 6)
            }
        }
        .multilineTextAlignment(.center)
        .padding(16)
        .background(.bgMain)
        .cornerRadius(10)
        .foregroundStyle(.bgSecondary)
    }
}

#Preview {
    TitleProgressCard(title: "Apakah semua Murid hadir?", subtitle: "Pilih murid Anda yang hadir untuk mengikuti aktivitas hari ini.")
}
