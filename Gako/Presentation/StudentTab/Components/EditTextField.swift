//
//  EditTextField.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct EditTextField: View {
    // MARK: - Constants
    private let textColor = UIConstants.Edit.textColor
    private let backgroundColor = UIConstants.Edit.backgroundColor
    private let strokeColor = UIConstants.Edit.strokeColor
    private let cornerRadius = UIConstants.Edit.cornerRadius
    private let strokeWidth = UIConstants.Edit.strokeWidth
    private let padding = UIConstants.Edit.innerSpacing
    
    // MARK: - Properties
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
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
