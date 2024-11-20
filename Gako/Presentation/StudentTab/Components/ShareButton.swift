//
//  ShareButton.swift
//  Breesix
//
//  Created by Rangga Biner on 03/11/24.
//

import SwiftUI

struct ShareButton: View {
    // MARK: - Constants
    private let verticalPadding = UIConstants.Share.verticalPadding
    private let cornerRadius = UIConstants.Share.cornerRadius
    private let textColor = UIConstants.Share.textColor
    private let iconFont = UIConstants.Share.iconFont
    private let titleFont = UIConstants.Share.titleFont
    
    // MARK: - Properties
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
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

#Preview {
    ShareButton(title: "Share", icon: "square.and.arrow.up.fill", color: .blue, action: { print("shared")})
}
