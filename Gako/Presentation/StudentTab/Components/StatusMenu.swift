//
//  StatusMenu.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A dropdown menu component for selecting student activity status
//  Usage: Use this menu to allow selection between different activity status options
//

import SwiftUI

struct StatusMenu: View {
    // MARK: - Constants
    private let textColor = UIConstants.StatusMenu.textColor
    private let background = UIConstants.StatusMenu.statusMenuBackground
    private let spacing = UIConstants.StatusMenu.statusMenuSpacing
    private let padding = UIConstants.StatusMenu.statusMenuPadding
    private let cornerRadius = UIConstants.StatusMenu.cornerRadius
    private let menuIcon = UIConstants.StatusMenu.statusMenuIcon
    private let mandiriText = UIConstants.StatusMenu.mandiriText
    private let dibimbingText = UIConstants.StatusMenu.dibimbingText
    private let tidakMelakukanText = UIConstants.StatusMenu.tidakMelakukanText
    
    // MARK: - Properties
    @Binding var selectedStatus: Status
    
    // MARK: - Body
    var body: some View {
        Menu {
            Button(mandiriText) { selectedStatus = .mandiri }
            Button(dibimbingText) { selectedStatus = .dibimbing }
            Button(tidakMelakukanText) { selectedStatus = .tidakMelakukan }
        } label: {
            HStack(spacing: spacing) {
                Text(selectedStatus.displayText)
                Image(systemName: menuIcon)
            }
            .font(.body)
            .fontWeight(.regular)
            .foregroundColor(textColor)
            .padding(padding)
            .background(background)
            .cornerRadius(cornerRadius)
        }
    }
}

// MARK: - Preview
#Preview {
    StatusMenu(selectedStatus: .constant(.dibimbing))
}
