//
//  EmptyState.swift
//  Breesix
//
//  Created by Rangga Biner on 23/10/24.
//

import SwiftUI

struct EmptyState: View {
    let message: String
    let imageName: String
    
    init(
        message: String,
        imageName: String = "note.text"
    ) {
        self.message = message
        self.imageName = imageName
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: imageName)
                .font(.system(size: 105))
                .opacity(0.1)
            Text(message)
                .opacity(0.5)
        }
    }
}

#Preview {
    EmptyState(message: "Belum ada catatan di hari ini.")
}
