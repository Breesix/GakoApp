//
// StudentTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI
import Speech

struct StudentTabView: View {
    @ObservedObject var studentTabViewModel: StudentTabViewModel
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
                
                VStack(spacing: 0) {
                    CustomNavigation(title: "Murid") {
                        isAddingStudent = true
                    }
                    CustomSearchBar(text: $searchQuery)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                    VStack {
                        if studentTabViewModel.students.isEmpty {
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
                                        NavigationLink {
                                            StudentDetailView(
                                                student: student,
                                                onAddStudent: { student in
                                                    await studentTabViewModel.addStudent(student)
                                                },
                                                onUpdateStudent: { student in
                                                    await studentTabViewModel.updateStudent(student)
                                                },
                                                onAddNote: { note, student in
                                                    await studentTabViewModel.addNote(note, for: student)
                                                },
                                                onUpdateNote: { note in
                                                    await studentTabViewModel.updateNote(note)
                                                },
                                                onDeleteNote: { note, student in
                                                    await studentTabViewModel.deleteNote(note, from: student)
                                                },
                                                onAddActivity: { activity, student in
                                                    await studentTabViewModel.addActivity(activity, for: student)
                                                },
                                                onDeleteActivity: { activity, student in
                                                    await studentTabViewModel.deleteActivities(activity, from: student)
                                                },
                                                onUpdateActivityStatus: { activity, isIndependent in
                                                    await studentTabViewModel.updateActivityStatus(activity, isIndependent: isIndependent)
                                                },
                                                onFetchNotes: { student in
                                                    await studentTabViewModel.fetchAllNotes(student)
                                                },
                                                onFetchActivities: { student in
                                                    await studentTabViewModel.fetchActivities(student)
                                                },
                                                onCheckNickname: { nickname, currentStudentId in
                                                    studentTabViewModel.students.contains { student in
                                                        if let currentId = currentStudentId {
                                                            return student.nickname.lowercased() == nickname.lowercased() && student.id != currentId
                                                        }
                                                        return student.nickname.lowercased() == nickname.lowercased()
                                                    }
                                                },
                                                compressedImageData: studentTabViewModel.compressedImageData
                                            )
                                        } label: {
                                            ProfileCard(student: student) {
                                                Task {
                                                    await studentTabViewModel.deleteStudent(student)
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
            await studentTabViewModel.fetchAllStudents()
        }
        .sheet(isPresented: $isAddingStudent) {
            ManageStudentView(
                mode: .add,
                compressedImageData: studentTabViewModel.compressedImageData,
                newStudentImage: studentTabViewModel.newStudentImage,
                onSave: { student in
                    await studentTabViewModel.addStudent(student)
                },
                onUpdate: { student in
                    await studentTabViewModel.updateStudent(student)
                },
                onImageChange: { image in
                    studentTabViewModel.newStudentImage = image
                },
                checkNickname: { nickname, currentStudentId in
                    studentTabViewModel.students.contains { student in
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
            await studentTabViewModel.fetchAllStudents()
        }
    }
    
    private var filteredStudents: [Student] {
        if searchQuery.isEmpty {
            return studentTabViewModel.students
        } else {
            return studentTabViewModel.students.filter { student in
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
