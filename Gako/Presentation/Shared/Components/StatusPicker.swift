//
//  StatusPicker.swift
//  Gako
//
//  Created by Rangga Biner on 01/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component that display status picker
//  Usage: Use this component to display status picker
//

import SwiftUI
import Mixpanel

struct StatusPicker: View {
    @Binding var status: Status
    var onStatusChange: (Status) -> Void
    
    var symbol = UIConstants.StatusPicker.symbol
    var primaryText = UIConstants.StatusPicker.textPrimary
    var stroke = UIConstants.StatusPicker.stroke
    var verticalPadding = UIConstants.StatusPicker.verticalPadding
    var horizontalPadding = UIConstants.StatusPicker.horizontalPadding
    var borderWidth = UIConstants.StatusPicker.borderWidth
    var cornerRadius = UIConstants.StatusPicker.cornerRadius
    
    var body: some View {
        Menu {
            ForEach(Status.allCases, id: \.self) { statusOption in
                Button(statusOption.text) {
                    status = statusOption
                    onStatusChange(statusOption)
                }
            }
        } label: {
            HStack {
                Text(status.text)
                    .font(.body)
                Spacer()
                Image(systemName: symbol)
            }
            .font(.body)
            .fontWeight(.regular)
            .foregroundColor(primaryText)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .cornerRadius(cornerRadius)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(stroke, lineWidth: borderWidth)
            }
        }
    }
}

#Preview {
    StatusPicker(status: .constant(.mandiri), onStatusChange: {_ in })
}
