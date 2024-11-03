//
// StudentTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI
import Speech

struct StudentTabView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @State private var isAddingStudent = false
    @State private var isAddingNote = false
    @State private var searchQuery = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.bgMain
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissKeyboard()
                    }
                
                VStack (spacing: 0) {
                    CustomNavigation(title: "Murid") {
                        isAddingStudent = true
                    }
                    CustomSearchBar(text: $searchQuery)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    Group {
                        if viewModel.students.isEmpty {
                            VStack {
                                Spacer()
                                EmptyState(message: "Belum ada murid yang terdaftar.")
                                Spacer()
                            }
                        } else if filteredStudents.isEmpty {
                            VStack {
                                Spacer()
                                EmptyState(message: "Tidak ada murid yang sesuai dengan pencarian.")
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    ForEach(filteredStudents) { student in
                                        NavigationLink(destination: StudentDetailView(student: student, viewModel: viewModel)) {
                                            ProfileCard(student: student) {
                                                Task {
                                                    await viewModel.deleteStudent(student)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .simultaneousGesture(DragGesture().onChanged({ _ in
                                dismissKeyboard()
                            }))
                        }
                    }
                }
            }
            .background(.bgMain)
            .navigationBarHidden(true)
        }
        .refreshable {
            await viewModel.fetchAllStudents()
        }
        .sheet(isPresented: $isAddingStudent) {
            EditStudent(
                mode: .add,
                compressedImageData: viewModel.compressedImageData,
                newStudentImage: viewModel.newStudentImage,
                onSave: { student in
                    await viewModel.addStudent(student)
                },
                onUpdate: { student in
                    await viewModel.updateStudent(student)
                },
                onImageChange: { image in
                    viewModel.newStudentImage = image
                },
                checkNickname: { nickname, currentStudentId in
                    viewModel.students.contains { student in
                        if let currentId = currentStudentId {
                            return student.nickname.lowercased() == nickname.lowercased() && student.id != currentId
                        }
                        return student.nickname.lowercased() == nickname.lowercased()
                    }
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.fetchAllStudents()
        }
    }
    
    private var filteredStudents: [Student] {
        if searchQuery.isEmpty {
            return viewModel.students
        } else {
            return viewModel.students.filter { student in
                student.nickname.localizedCaseInsensitiveContains(searchQuery) ||
                student.fullname.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil,
                                      from: nil,
                                      for: nil)
    }
}
