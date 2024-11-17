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
        HStack(alignment: .center, spacing: 10) {
            Text(text)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.42, green: 0.69, blue: 0.27))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(red: 0.42, green: 0.69, blue: 0.27).opacity(0.25))
        .cornerRadius(82)
        .overlay(
            RoundedRectangle(cornerRadius: 82)
                .stroke(Color(red: 0.42, green: 0.69, blue: 0.27).opacity(0.25), lineWidth: 0.5)
                .shadow(color: Color(red: 0.42, green: 0.69, blue: 0.27), radius: 1.5, x: 0, y: 0)
        )
    }
}

#Preview {
    GuidingQuestionTag(text: "Apakah aktivitas dijalankan dengan baik?")
}
