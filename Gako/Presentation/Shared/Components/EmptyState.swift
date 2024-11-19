//
//  EmptyState.swift
//  Gako
//
//  Created by Rangga Biner on 23/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component that display empty state
//  Usage: Use this component to display empty state
//

import SwiftUI

struct EmptyState: View {
    let message: String
    
    var textColor: Color = UIConstants.EmptyState.textColor
    var defaultSpacing: CGFloat = UIConstants.EmptyState.defaultSpacing
    var width: CGFloat = UIConstants.EmptyState.width
    var image: String = UIConstants.EmptyState.image
    
    var body: some View {
        VStack(spacing: defaultSpacing) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: width)
            Text(message)
                .foregroundStyle(textColor)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    EmptyState(message: "Belum ada catatan di hari ini.")
}
