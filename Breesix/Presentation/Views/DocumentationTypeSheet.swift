//
//  DocumentationTypeSheet.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import SwiftUI

struct DocumentationTypeSheet: View {
    var body: some View {
        VStack  {
            Button(action: {
                print("Suara")
            }, label: {
                VStack (alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "mic.fill")
                        VStack (alignment: .leading){
                            Text("Suara")
                                .font(.headline)
                            Text("Ceritakan Melalui Suara")
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

            })
            Button(action: {
                print("Tulisan")
            }, label: {
                VStack (alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "pencil.circle")
                        VStack (alignment: .leading){
                            Text("Tulisan")
                                .font(.headline)
                            Text("Ceritakan Melalui Tulisan")
                                .font(.subheadline)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

            })
        }
        .safeAreaPadding()
    }
}

#Preview {
    DocumentationTypeSheet()
}
