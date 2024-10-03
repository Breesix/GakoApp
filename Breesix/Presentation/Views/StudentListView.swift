//
//  StudentListView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI

struct StudentListView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @State private var isAddingStudent = false
    @State private var isAddingActivity = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    NavigationLink(destination: StudentDetailView(student: student, viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "person.crop.circle")
                            VStack(alignment: .leading) {
                                Text(student.nickname)
                                    .font(.headline)
                                Text(student.fullname)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        Task {
                            await viewModel.deleteStudent(viewModel.students[index])
                        }
                    }
                }
            }
            .navigationTitle("Daftar Murid")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isAddingStudent = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        Task {
                            await viewModel.loadStudents()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Tambah Catatan") {
                        isAddingActivity = true
                    }
                }
            }
        }
        .refreshable {
            await viewModel.loadStudents()
        }
        .sheet(isPresented: $isAddingStudent) {
            StudentEditView(viewModel: viewModel, mode: .add)
        }
        .sheet(isPresented: $isAddingActivity) {
            ActivityFormView(viewModel: viewModel, isPresented: $isAddingActivity)
        }
        .task {
            await viewModel.loadStudents()
        }
    }
}



