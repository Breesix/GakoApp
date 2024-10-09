//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct ActivityCardView: View {
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    // Footnote/Emphasized
                    Text("Toilet Training")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                      .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Independent")
                    }
                    .foregroundColor(.green)
                    HStack(alignment: .center, spacing: 10) {
                        Text("Sudah bisa pipis sendiri")
                            .font(.caption)
                        .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))

                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .frame(width: .infinity, alignment: .center)
                    .background(.white)
                    .cornerRadius(8)
                }
                .padding(0)
                VStack(alignment: .leading, spacing: 8) {
                    // Footnote/Emphasized
                    Text("Aktivitas Umum")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                      .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
                    ForEach (0..<3) { index in
                        HStack(alignment: .center, spacing: 10) {
                            Text("Sudah bisa pipis sendiri")
                                .font(.caption)
                            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(width: .infinity, alignment: .center)
                        .background(.white)
                        .cornerRadius(8)
                    }
                    Button(action: {}) {
                        Label("Tambah", systemImage: "plus.app.fill")
                    }
                    .buttonStyle(.bordered)
                }
                .padding(0)

            }
            .padding(.horizontal, 12)
            .padding(.vertical, 0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color(red: 0.92, green: 0.96, blue: 0.96))
        .cornerRadius(8)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .inset(by: 0.25)
            .stroke(.brown, lineWidth: 0.5)
        )
    }
}

#Preview {
    ActivityCardView()
}
