//
//  StudentListView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI

struct StudentListView: View {
    @StateObject var viewModel: StudentListViewModel
    @State private var isAddingStudent = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    NavigationLink(destination: StudentDetailView(student: student, viewModel: viewModel)) {
                        VStack(alignment: .leading) {
                            Text(student.fullname)
                                .font(.headline)
                            Text(student.nickname)
                                .font(.subheadline)
                                .lineLimit(1)
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
            .navigationTitle("Students")
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
            }
            .refreshable {
                await viewModel.loadStudents()
            }
            .sheet(isPresented: $isAddingStudent) {
                StudentEditView(viewModel: viewModel, mode: .add)
            }
        }
        .task {
            await viewModel.loadStudents()
        }
    }
}

struct StudentDetailView: View {
    let student: Student
    @ObservedObject var viewModel: StudentListViewModel
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(student.fullname)
                .font(.title)
            Text(student.nickname)
                .font(.body)
        }
        .padding()
        .navigationBarItems(trailing: Button("Edit") {
            isEditing = true
        })
        .sheet(isPresented: $isEditing) {
            StudentEditView(viewModel: viewModel, mode: .edit(student))
        }
    }
}

struct StudentEditView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var fullname = ""
    @State private var nickname = ""
    
    enum Mode: Equatable {
        case add
        case edit(Student)
        
        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.add, .add):
                return true
            case let (.edit(student1), .edit(student2)):
                return student1.id == student2.id
            default:
                return false
            }
        }
    }
    
    let mode: Mode
    
    init(viewModel: StudentListViewModel, mode: Mode) {
        self.viewModel = viewModel
        self.mode = mode
        
        switch mode {
        case .add:
            _fullname = State(initialValue: "")
            _nickname = State(initialValue: "")
        case .edit(let student):
            _fullname = State(initialValue: student.fullname)
            _nickname = State(initialValue: student.nickname)
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $fullname)
                TextEditor(text: $nickname)
            }
            .navigationTitle(mode == .add ? "Add Student" : "Edit Student")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveStudent()
            })
        }
    }
    
    private func saveStudent() {
        Task {
            switch mode {
            case .add:
                let newStudent = Student(fullname: fullname, nickname: nickname)
                await viewModel.addStudent(newStudent)
            case .edit(let student):
                student.fullname = fullname
                student.nickname = nickname
                await viewModel.updateStudent(student)
            }
            presentationMode.wrappedValue.dismiss()
        }
    }
}

