//
//  ToastNotification.swift
//  Gako
//
//  Created by Rangga Biner on 18/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom component that display toast for the status
//  Usage: Use this component to display toast
//

import SwiftUI

struct ToastNotification: View {
    var message: String
    var width = CGFloat.infinity
    var onCancelTapped: (() -> Void)
    
    var bgColor: Color = UIConstants.ToastNotification.bgColor
    var cancelSymbol: String = UIConstants.ToastNotification.cancelSymbol
    var spacing: CGFloat = UIConstants.ToastNotification.spacing
    var minSpacerLength: CGFloat = UIConstants.ToastNotification.minSpacerLength
    var padding: CGFloat = UIConstants.ToastNotification.padding
    var cornerRadius: CGFloat = UIConstants.ToastNotification.cornerRadius
    var style: UIConstants.ToastNotification.Style
    
    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            Image(systemName: style.iconFileName)
                .foregroundColor(style.themeColor)
            
            Text(message)
                .font(.caption)
                .foregroundColor(.white)
            
            Spacer(minLength: minSpacerLength)
            
            Button {
                onCancelTapped()
            } label: {
                Image(systemName: cancelSymbol)
                    .foregroundColor(style.themeColor)
            }
        }
        .padding()
        .frame(maxWidth: width)
        .background(bgColor)
        .cornerRadius(cornerRadius)
        .padding(.horizontal, padding)
    }
}

#Preview {
    ToastNotification(message: "Sukses", onCancelTapped: {}, style: .success)
}
