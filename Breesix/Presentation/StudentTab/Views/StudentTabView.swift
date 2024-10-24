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
            VStack(alignment: .center, spacing: 8) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 104, height: 104)
                    .background(
                        Group {
                            if let imageData = student.imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 104, height: 104)
                                    .clipped()
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 104, height: 104)
                            }
                        }
                    )
                    .cornerRadius(999)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .inset(by: 2.5)
                            .stroke(.white, lineWidth: 5)
                    )
                VStack(alignment: .center, spacing: 8) {
                    Text(student.nickname)
                        .font(.body)
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 21, maxHeight: 21, alignment: .center)
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(.white)
                .cornerRadius(32)
            }
        }
        .contextMenu {
            Button(action: onDelete) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

struct StudentTabView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @State private var isAddingStudent = false
    @State private var isAddingNote = false
    @State private var searchQuery = "" // State for search query
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    // Filter students based on search query
                    ForEach(filteredStudents) { student in
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
            .background(.bgMain)
            .navigationTitle("Daftar Murid")
            .searchable(text: $searchQuery) // Add searchable modifier
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
            }
        }
        .tint(.white)
        .refreshable {
            await viewModel.fetchAllStudents()
        }
        .sheet(isPresented: $isAddingStudent) {
            StudentEditView(viewModel: viewModel, mode: .add)
        }
        .task {
            await viewModel.fetchAllStudents()
        }
    }
    
    // Computed property to filter students based on the search query
    private var filteredStudents: [Student] {
        if searchQuery.isEmpty {
            return viewModel.students // Return all students if no search query
        } else {
            return viewModel.students.filter { student in
                // Check if nickname or fullname contains the search query (case insensitive)
                student.nickname.localizedCaseInsensitiveContains(searchQuery) ||
                student.fullname.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}