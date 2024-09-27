//
//  AddSheet.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import SwiftUI

struct AddSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            Button(action: {
                print("person")
            }, label: {
                HStack {
                    Image(systemName: "person.fill.badge.plus")
                    Text("Tambah Murid")
                }
            })
            .padding(.bottom, 30)
            Button(action: {
                viewModel.isAddSheetPresented = false
                viewModel.isAddDocumentationPresented = true
            }, label: {
                HStack {
                    Image(systemName: "doc.badge.plus")
                    Text("Tambah Dokumentasi")
                }
            })
        }
    }
}

#Preview {
    AddSheet(viewModel: HomeViewModel())
}
