//
//  AddDocumentationView.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import SwiftUI

struct AddDocumentationView: View {
    @StateObject private var viewModel = AddDocumentationViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Klik untuk tambah dokumentasi")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(viewModel.students, id: \.id) { student in
                        Button(action: {
                            print("Button tapped for \(student.name)")
                        }) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                Text(student.name)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    Button(action: {
                        print("Button tapped for Tambah dokumentasi")
                    }) {
                        Text("Tambah Dokumentasi")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Tambah Dokumentasi")
        }
    }
}
#Preview {
    AddDocumentationView()
}
