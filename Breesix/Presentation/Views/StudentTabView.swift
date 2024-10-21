//
// StudentTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI

struct StudentListCard: View {
    let student: Student
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                if let imageData = student.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 104, height: 104)
                        .clipped()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 104, height: 104)
                }
                VStack(alignment: .center, spacing: 8) {
                    Text(student.nickname)
                        .font(.body)
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .lineLimit(1)
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .padding(0)
        .frame(minWidth: 120, maxWidth: .infinity, alignment: .topLeading)
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 1.5)
                .stroke(.white, lineWidth: 3)
        )
        .contextMenu {
            Button(action: onDelete) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

struct StudentTabView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @State private var isAddingStudent = false
    @State private var isAddingNote = false

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(viewModel.students) { student in
                        NavigationLink(destination: StudentDetailView(student: student, viewModel: viewModel)) {
                            StudentListCard(student: student) {
                                Task {
                                    await viewModel.deleteStudent(student)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .background(Color(hex: "EAF0E4"))
            .navigationTitle("Daftar Murid")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Tambah", systemImage: "plus.app.fill", action: { isAddingStudent = true })
                    .labelStyle(.titleAndIcon)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .tint(.white)
                    .foregroundStyle(.black)
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
        .task {
//            await viewModel.fetchAllStudents()
        }
    }
}
