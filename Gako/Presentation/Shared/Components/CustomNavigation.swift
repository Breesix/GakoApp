//
//  CustomNavigation.swift
//  Breesix
//
//  Created by Rangga Biner on 23/10/24.
//

import SwiftUI

struct CustomNavigation: View {
    var title: String
    var textButton: String
    var isInternetConnected: Bool
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
                    
                    AddItemButton(
                        onTapAction: action,
                        bgColor: .white,
                        text: textButton
                    )

                }
                .padding(.horizontal, 16)
            }
        }
        .frame(height: 58)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

//#Preview {
//    VStack {
//        CustomNavigation(title: "Ringkasan", action: {print("clicked")})
//        Spacer()
//    }
//}
