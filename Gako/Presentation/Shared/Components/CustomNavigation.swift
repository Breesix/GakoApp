//
//  CustomNavigation.swift
//  Gako
//
//  Created by Rangga Biner on 23/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component that display navigation bar
//  Usage: Use this component to display a navigation bar
//

import SwiftUI

struct CustomNavigation: View {
    var title: String
    var textButton: String
    var action: () -> Void
    
    var bgColor: Color = UIConstants.CustomNavigation.bgColor
    var cornerRadius: CGFloat = UIConstants.CustomNavigation.cornerRadius
    var padding: CGFloat = UIConstants.CustomNavigation.padding
    var height: CGFloat = UIConstants.CustomNavigation.height

    var body: some View {
        ZStack {
            Color(bgColor)
                .cornerRadius(cornerRadius, corners: [.bottomLeft, .bottomRight])
                .ignoresSafeArea(edges: .top)
            
            HStack {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    
                Spacer()
                
                AddItemButton(
                    onTapAction: action,
                    bgColor: .white,
                    text: textButton
                )
            }
            .padding(.horizontal, padding)
        }
        .frame(height: height)
    }
}

#Preview {
    CustomNavigation(title: "Dokumentasi", textButton: "Dokumentasi", action: {})
    Spacer()
}
