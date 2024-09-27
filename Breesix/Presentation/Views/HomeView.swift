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
            ZStack(alignment: .bottom) {
                    VStack {
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
                            ScrollView {
                                ForEach(viewModel.students, id: \.name) { student in
                                    StudentRowCard(student: student)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color(UIColor.systemBackground))
                            }
                        }
                    }
                    .safeAreaPadding()
                
                Button(action: {
                    viewModel.isDocumentationTypeSheetPresented = true
                }) {
                    Text("Tambah Bersamaan")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Dokumentasi Murid")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.isAddSheetPresented = true
                    }) {
                        Text("+ Tambah")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $viewModel.isDocumentationTypeSheetPresented) {
                DocumentationTypeSheet()
                    .presentationDetents([.height(250)])
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
