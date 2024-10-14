//
// StudentTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI

struct StudentTabView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @State private var isAddingStudent = false
    @State private var isAddingNote = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    NavigationLink(destination: StudentDetailView(student: student, viewModel: viewModel)) {
                        HStack {
                            if let imageData = student.imageData {
                                Image(uiImage: UIImage(data: imageData)!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                            }
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
                            await viewModel.fetchAllStudents()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Tambah Catatan") {
                        isAddingNote = true
                    }
                }
            }
        }
        .refreshable {
            await viewModel.fetchAllStudents()
        }
        .sheet(isPresented: $isAddingStudent) {
            StudentEditView(viewModel: viewModel, mode: .add)
        }
        .sheet(isPresented: $isAddingNote) {
            NoteFormView(viewModel: viewModel, isPresented: $isAddingNote)
        }
        .task {
            await viewModel.fetchAllStudents()
        }
    }
}


