//
//  ShareButton.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import SwiftUI

struct ShareButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .cornerRadius(10)
        }
    }
}

#Preview {
    ShareButton(title: "Share", icon: "square.and.arrow.up.fill", color: .blue, action: { print("shared")})
}
