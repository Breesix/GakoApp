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
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background view to handle taps
                Color.bgMain
                    .dismissKeyboardOnTap()
                
                VStack {
                    CustomNavigationBar(title: "Daftar Murid") {
                        isAddingStudent = true
                    }
                    CustomSearchBar(text: $searchQuery)
                        .padding(.vertical)
                    
                    if viewModel.students.isEmpty {
                        Spacer()
                        EmptyState(message: "Belum ada murid yang terdaftar.")
                    } else if filteredStudents.isEmpty {
                        Spacer()
                        EmptyState(message: "Tidak ada murid yang sesuai dengan pencarian.")
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
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
                    }
                    
                    Spacer()
                }
            }
            .background(Color.bgMain)
        }
        .searchable(text: $searchQuery)
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

struct CustomSearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if !text.isEmpty {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
                .padding(.horizontal, 10)
                .onTapGesture {
                    withAnimation {
                        self.isEditing = true
                    }
                }
            
            if isEditing {
                Button(action: {
                    withAnimation {
                        self.isEditing = false
                        self.text = ""
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                        to: nil,
                                                        from: nil,
                                                        for: nil)
                    }
                }) {
                    Text("Cancel")
                        .foregroundStyle(.destructive)
                }
                .padding(.trailing, 10)
            }
        }
    }
}
