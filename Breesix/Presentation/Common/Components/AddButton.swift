//
//  AddButton.swift
//  Breesix
//
//  Created by Rangga Biner on 23/10/24.
//

import SwiftUI

struct AddButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.app.fill")
                    .font(.system(.footnote))
                Text("Tambah")
                    .font(.subheadline)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .font(.footnote)
            .fontWeight(.regular)
            .foregroundStyle(.buttonPrimaryLabel)
            .background(.buttonPrimaryOnGreen)
            .cornerRadius(8)
        }
    }
}

#Preview {
    AddButton(action: {print("clicked")})
}
