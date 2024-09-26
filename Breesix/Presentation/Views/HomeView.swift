//
//  HomeView.swift
//  Breesix
//
//  Created by Rangga Biner on 23/09/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Dokumentasi Murid")
                    Spacer()
                    Button(action: {
                        viewModel.isAddSheetPresented = true
                    }, label: {
                        Text("+ Tambah")
                    })
                }
                Divider()
                
                if viewModel.students.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text("Belum ada murid")
                    }
                    Spacer()
                } else {
                    List(viewModel.students, id: \.name) { student in
                        NavigationLink(destination: StudentDetailView(student: student)) {
                            Text(student.name)
                        }
                    }
                }
            }
            .safeAreaPadding()
            .sheet(isPresented: $viewModel.isAddSheetPresented) {
                AddSheet(viewModel: viewModel)
                    .presentationDetents([.height(200)])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.isAddDocumentationPresented) {
                AddDocumentationView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

struct StudentDetailView: View {
    let student: Student

    var body: some View {
        Text("Details for \(student.name)")
    }
}



#Preview {
    HomeView()
}
