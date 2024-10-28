//
//  ProfileHeader.swift
//  Breesix
//
//  Created by Akmal Hakim on 15/10/24.
//

import SwiftUI

struct MuridListHeader: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            HStack(alignment: .center) {
                Text("Murid Euy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .kerning(0.38)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(red: 0.43, green: 0.64, blue: 0.32)
                .clipShape(
                    RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight])
                )
        )
    }
}

#Preview {
    MuridListHeader()
}
