//
//  InsigtVIew.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/10/24.
//

import SwiftUI

struct InsigtVIew: View {
    var body: some View {
        // Insight section
        VStack(alignment: .leading) {
            Text("Insight Hari ini")
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.vertical)
            
            Text("Tulis insight atau catatan penting di sini...")
                .font(.footnote)
                .frame(maxWidth: .infinity, minHeight: 100)
                .padding()
                .background(Color.gray)
                .cornerRadius(8)
        }
        .padding()
        .background(
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, minHeight: 100)
        )
    }
}

#Preview {
    InsigtVIew()
}
