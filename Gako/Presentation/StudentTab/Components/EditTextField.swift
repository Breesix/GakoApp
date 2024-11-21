//
//  EditTextField.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom styled text field component for editing text
//  Usage: Use this reusable text field component for text input throughout the app
//

import SwiftUI

struct EditTextField: View {
    // MARK: - Constants
    private let textColor = UIConstants.EditTextField.textColor
    private let backgroundColor = UIConstants.EditTextField.backgroundColor
    private let strokeColor = UIConstants.EditTextField.strokeColor
    private let cornerRadius = UIConstants.EditTextField.cornerRadius
    private let strokeWidth = UIConstants.EditTextField.strokeWidth
    private let padding = UIConstants.EditTextField.innerSpacing
    
    // MARK: - Properties
    @Binding var text: String
    var placeholder: String = ""
    
    // MARK: - Body
    var body: some View {
        textField
    }
    
    // MARK: - Subview
    private var textField: some View {
        TextField(placeholder, text: $text)
            .font(.subheadline)
            .fontWeight(.regular)
            .foregroundStyle(textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(strokeColor, lineWidth: strokeWidth)
            }
    }
}

// MARK: - Preview
#Preview {
    EditTextField(text: .constant("Sample text"), placeholder: "sample holder")
}
