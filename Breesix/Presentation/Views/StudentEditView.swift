//
//  StudentEditView.swift
//  Breesix
//
//  Created by Rangga Biner on 03/10/24.
//

import SwiftUI

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
                TextField("Nama Panggilan", text: $nickname)
                TextField("Nama Lengkap", text: $fullname)
            }
            .navigationTitle(mode == .add ? "Tambah Murid" : "Edit Murid")
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

