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
    @State private var isAddingNote = false

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
                        isAddingNote = true
                    }
                }
            }
            .refreshable {
                await viewModel.loadStudents()
            }
            .sheet(isPresented: $isAddingStudent) {
                StudentEditView(viewModel: viewModel, mode: .add)
            }
            .sheet(isPresented: $isAddingNote) {
                NoteFormView(viewModel: viewModel, isPresented: $isAddingNote)
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
    @State private var notes: [Note] = []
    @State private var selectedDate = Date()
    @State private var selectedNote: Note?

    var body: some View {
        List {
            Section(header: Text("Informasi Murid")) {
                Text("Nama Lengkap: \(student.fullname)")
                Text("Nama Panggilan: \(student.nickname)")
            }

            Section(header: Text("Pilih Tanggal")) {
                DatePicker("Tanggal", selection: $selectedDate, displayedComponents: .date)
                    .onChange(of: selectedDate) { oldValue, newValue in
                        Task {
                            await loadNotes()
                        }
                    }
            }

            Section(header: Text("Catatan")) {
                if filteredNotes.isEmpty {
                    Text("Tidak ada catatan untuk tanggal ini")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(filteredNotes, id: \.id) { note in
                        VStack(alignment: .leading) {
                            Text("Aktivitas Umum: \(note.generalActivity)")
                            Text("Catatan Toilet Training: \(note.toiletTraining)")
                            Text("Status Toilet Training: \(note.toiletTrainingStatus ? "Ya" : "Tidak")")
                        }
                        .contextMenu {
                            Button("Edit") {
                                print("Edit button tapped for note: \(note.id)")
                                self.selectedNote = note
                                print("selectedNote set to: \(String(describing: self.selectedNote))")
                            }
                            Button("Hapus", role: .destructive) {
                                deleteNote(note)
                            }

                        }
                    }
                }
            }
            .onChange(of: viewModel.students) { _, _ in
                Task {
                    await loadNotes()
                }
            }
        }
        .navigationTitle(student.nickname)
        .navigationBarItems(trailing: Button("Edit") {
            isEditing = true
        })
        .sheet(isPresented: $isEditing) {
            StudentEditView(viewModel: viewModel, mode: .edit(student))
        }
        .sheet(item: $selectedNote) { note in
            NoteEditView(viewModel: viewModel, note: note, onDismiss: {
                selectedNote = nil
            })
        }
        .task {
            await loadNotes()
        }
        .onAppear {
            print("StudentDetailView appeared")
        }
        .onDisappear {
            print("StudentDetailView disappeared")
        }
        .onChange(of: selectedNote) { oldValue, newValue in
            print("selectedNote changed: \(String(describing: newValue))")
        }
    }

    private func loadNotes() async {
        notes = await viewModel.getNotesForStudent(student)
        print("Loaded \(notes.count) notes for student")
    }

    private var filteredNotes: [Note] {
        let filtered = notes.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate) }
        print("Filtered notes count: \(filtered.count)")
        return filtered
    }
    
    private func deleteNote(_ note: Note) {
        Task {
            await viewModel.deleteNote(note, from: student)
            notes.removeAll(where: { $0.id == note.id })
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

