//
//  AddDocumentationDetailView.swift
//  Breesix
//
//  Created by Rangga Biner on 27/09/24.
//

import SwiftUI

struct AddDocumentationDetailView: View {
    @StateObject private var viewModel = AddDocumentationDetailViewModel()
    @State private var extraNotes: String = ""
    let student: Student
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Kegiatan")) {
                    ForEach(viewModel.activities, id: \.title) { activity in
                        ActivityRow(activity: activity)
                    }
                    .listRowBackground(Color(UIColor.systemBackground))
                }
                
                Section(header: Text("Catatan Tambahan")) {
                    TextEditor(text: $extraNotes)
                        .frame(minHeight: 100)
                        .background(Color(UIColor.systemBackground))
                }
            }
            .listStyle(PlainListStyle())
            Button(action: {
                print("submit yummy")
            }, label: {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            })
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("\(student.name)")
                            .font(.headline)
                    }
                }
            }
        }
    }
}

#Preview {
    // must change adddocumentationdetailview sebaiknya tidak ada argumen
    AddDocumentationDetailView(student: Student(name: "rangga", nickname: "dsahjkbf"))
}
