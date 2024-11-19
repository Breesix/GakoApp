//
//  AddItemButton.swift
//  Gako
//
//  Created by Rangga Biner on 23/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component that displays add item button
//  Usage: Use this component to display a button for the add something feature
//

import SwiftUI

struct AddItemButton: View {
    var onTapAction: () -> Void
    var bgColor: Color
    var text: String
    
    var symbol: String = UIConstants.AddItemButton.symbol
    var spacing: CGFloat = UIConstants.AddItemButton.spacing
    var verticalPadding: CGFloat = UIConstants.AddItemButton.verticalPadding
    var horizontalPadding: CGFloat = UIConstants.AddItemButton.horizontalPadding
    var cornerRadius: CGFloat = UIConstants.AddItemButton.cornerRadius
    var primaryText: Color = UIConstants.AddItemButton.primaryText

    var body: some View {
        Button(action: onTapAction) {
            HStack(spacing: spacing){
                Image(systemName: symbol)
                Text(text)
            }
            .fontWeight(.regular)
            .font(.subheadline)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .foregroundStyle(primaryText)
            .background(bgColor)
            .cornerRadius(cornerRadius)
        }
    }
}

#Preview {
        AddItemButton( onTapAction: { print("added") },bgColor: .white, text: "Dokumentasi")
}
