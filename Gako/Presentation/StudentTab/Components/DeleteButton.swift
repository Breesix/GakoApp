//
//  DeleteButton.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A reusable circular button component for delete actions
//  Usage: Use this button wherever delete functionality is needed
//

import SwiftUI

struct DeleteButton: View {
    // MARK: - Constants
    private let buttonSize = UIConstants.DeleteButton.deleteButtonSize
    private let buttonBackground = UIConstants.DeleteButton.deleteButtonBackground
    private let iconColor = UIConstants.DeleteButton.deleteIconColor
    
    // MARK: - Properties
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .frame(width: buttonSize)
                    .foregroundStyle(buttonBackground)
                Image(systemName: UIConstants.Edit.trashIcon)
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundStyle(iconColor)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    DeleteButton(action: {})
}
