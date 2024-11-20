//
//  StatusMenu.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI

struct StatusMenu: View {
    // MARK: - Constants
    private let textColor = UIConstants.ManageActivity.textColor
    private let background = UIConstants.ManageActivity.statusMenuBackground
    private let spacing = UIConstants.ManageActivity.statusMenuSpacing
    private let padding = UIConstants.ManageActivity.statusMenuPadding
    private let cornerRadius = UIConstants.ManageActivity.cornerRadius
    private let menuIcon = UIConstants.ManageActivity.statusMenuIcon
    private let mandiriText = UIConstants.ManageActivity.mandiriText
    private let dibimbingText = UIConstants.ManageActivity.dibimbingText
    private let tidakMelakukanText = UIConstants.ManageActivity.tidakMelakukanText
    
    @Binding var selectedStatus: Status
    
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

private extension Status {
    var displayText: String {
        switch self {
        case .mandiri: return UIConstants.ManageActivity.mandiriText
        case .dibimbing: return UIConstants.ManageActivity.dibimbingText
        case .tidakMelakukan: return UIConstants.ManageActivity.tidakMelakukanText
        }
    }
}
