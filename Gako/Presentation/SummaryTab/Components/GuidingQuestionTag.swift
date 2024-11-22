//
//  GuidingQuestionTag.swift
//  Breesix
//
//  Created by Akmal Hakim on 13/11/24.
//

import SwiftUI

struct GuidingQuestionTag: View {
    let text: String
    
    init(text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(Color.green400)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.green4002)
            .cornerRadius(82)
            .overlay(
                RoundedRectangle(cornerRadius: 82)
                    .stroke(Color.green4002, lineWidth: 0.5)
                    .shadow(color: Color.green400, radius: 1.5, x: 0, y: 0)
        )
    }
}

#Preview {
    GuidingQuestionTag(text: "Apakah aktivitas dijalankan dengan baik?")
}
