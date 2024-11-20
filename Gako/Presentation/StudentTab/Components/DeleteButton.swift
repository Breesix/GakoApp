//
//  DeleteButton.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct DeleteButton: View {
    // MARK: - Constants
    private let buttonSize = UIConstants.Edit.deleteButtonSize
    private let buttonBackground = UIConstants.Edit.deleteButtonBackground
    private let iconColor = UIConstants.Edit.deleteIconColor
    
    // MARK: - Properties
    let action: () -> Void
    
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
