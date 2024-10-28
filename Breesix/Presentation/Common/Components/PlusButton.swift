//
//  PlusButton.swift
//  Breesix
//
//  Created by Rangga Biner on 15/10/24.
//

import SwiftUI

struct PlusButton: View {
    var action: () -> Void
    var imageName: String
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageName)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
        }
    }
}


#Preview {
    PlusButton(action: {print("clicked")}, imageName: "plus.circle.fill")
}
