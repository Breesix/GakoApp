//
//  ShareButton.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A customizable button component for sharing actions
//  Usage: Use this button to implement sharing functionality with custom icons and colors
//

import SwiftUI

struct ShareButton: View {
    // MARK: - Constants
    private let verticalPadding = UIConstants.ShareButton.verticalPadding
    private let cornerRadius = UIConstants.ShareButton.cornerRadius
    private let textColor = UIConstants.ShareButton.textColor
    private let iconFont = UIConstants.ShareButton.iconFont
    private let titleFont = UIConstants.ShareButton.titleFont
    
    // MARK: - Properties
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(iconFont)
                Text(title)
                    .font(titleFont)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, verticalPadding)
            .background(color)
            .cornerRadius(cornerRadius)
        }
    }
}

// MARK: - Preview
#Preview {
    ShareButton(title: "Share", icon: "square.and.arrow.up.fill", color: .blue, action: { print("shared")})
}
