//  AddButton.swift
//  Breesix
//  Created by Rangga Biner on 23/10/24.

import SwiftUI

struct AddButton: View {
    var action: () -> Void
    var backgroundColor: Color
    var title: String

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.app.fill")
                    .font(.system(.footnote))
                Text(title)
                    .font(.subheadline)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .font(.footnote)
            .fontWeight(.regular)
            .foregroundStyle(.buttonPrimaryLabel)
            .background(backgroundColor)
            .cornerRadius(8)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AddButton(
            action: { print("clicked") },
            
            backgroundColor: .blue, title: "Dokumentasi"
        )
    }
}
