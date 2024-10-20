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
            // Profile Image
            HStack(alignment: .center) {
                // Space Between
                Text("Murid Euy")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .kerning(0.38)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                Spacer()
                // Alternative Views and Spacers
                
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
//    var body: some View {
//        
//        VStack(alignment: .leading, spacing: 0) {
//            Spacer()
//            HStack(alignment: .center) {
//                // Space Between
//                Text("Murid")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .kerning(0.38)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .topLeading)
//                Spacer()
//                // Alternative Views and Spacers
//                
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//            .frame(maxWidth: .infinity, alignment: .center)
//        }
//        .padding(.horizontal, 0)
//        .padding(.top, 0)
//        .padding(.bottom, 12)
//        .frame(maxWidth: .infinity, alignment: .topLeading)
//        .background(Color(red: 0.33, green: 0.49, blue: 0.29))
//        .cornerRadius(16)
//        .edgesIgnoringSafeArea(.top)
//        Spacer()
//    }
}

#Preview {
    MuridListHeader()
}
