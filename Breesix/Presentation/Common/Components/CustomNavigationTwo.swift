//
//  CustomNavigation.swift
//  Breesix
//
//  Created by Rangga Biner on 23/10/24.
//

import SwiftUI

struct CustomNavigationTwo: View {
    var title: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Color(.bgSecondary)
                .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Text(title)
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Spacer()
                    
                    AddButton(action: action)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(height: 58)
    }
}

#Preview {
    VStack {
        CustomNavigationBar(title: "Ringkasan", action: {print("lol")})
        Spacer()
    }
}
