//
// StudentTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI
import Speech

struct StudentTabView: View {
    
    
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @Binding var isAddingStudent: Bool
    @State private var isAddingNote = false
    @State private var searchQuery = ""
    
    var background = UIConstants.StudentTabView.backgroundColor
    var searchBarVerticalPadding = UIConstants.StudentTabView.searchBarVerticalPadding
    var searchBarHorizontalPadding = UIConstants.StudentTabView.searchBarHorizontalPadding
    var navigationTitle = UIConstants.StudentTabView.navigationTitle
    var navigationButtonText = UIConstants.StudentTabView.navigationButtonText
    var emptyStateMessageNoStudent = UIConstants.StudentTabView.emptyStateMessageNoStudent
    var gridSpacing = UIConstants.StudentTabView.gridSpacing
    var contentHorizontalPadding = UIConstants.StudentTabView.contentHorizontalPadding
    var backgroundColor = UIConstants.StudentTabView.backgroundColor
    
    var body: some View {
        NavigationStack {
            ZStack {
                background
                .ignoresSafeArea()
                .onTapGesture {
                        dismissKeyboard()
                    }
                
                VStack(spacing: 0) {
                    CustomNavigation(
                        title: navigationTitle,
                        textButton: navigationButtonText
                    ) {
                        isAddingStudent = true
                    }
                    CustomSearchBar(text: $searchQuery)
                         .padding(.vertical, searchBarVerticalPadding)
                        .padding(.horizontal, searchBarHorizontalPadding)
                    VStack {
                        if studentViewModel.students.isEmpty {
                            VStack {
                                Spacer()
                                EmptyState(message: emptyStateMessageNoStudent)
                                Spacer()
                            }
                        } else if filteredStudents.isEmpty {
                            VStack {
                                Spacer()
                                EmptyState(message: emptyStateMessageNoStudent)
                                Spacer()
                            }
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: gridSpacing) {
                                    ForEach(filteredStudents) { student in
                                        NavigationLink {
                                            MonthListView(
                                                student: student,
                                                onAddStudent: { student in
                                                    await studentViewModel.addStudent(student)
                                                },
                                                onUpdateStudent: { student in
                                                    await studentViewModel.updateStudent(student)
                                                },
                                                onAddNote: { note, student in
                                                    await noteViewModel.addNote(note, for: student)
                                                },
                                                onUpdateNote: { note in
                                                    await noteViewModel.updateNote(note)
                                                },
                                                onDeleteNote: { note, student in
                                                    await noteViewModel.deleteNote(note, from: student)
                                                },
                                                onAddActivity: { activity, student in
                                                    await activityViewModel.addActivity(activity, for: student)
                                                },
                                                onDeleteActivity: { activity, student in
                                                    await activityViewModel.deleteActivities(activity, from: student)
                                                },
                                                onUpdateActivityStatus: { activity, status in
                                                    await activityViewModel.updateActivityStatus(activity, status: status)
                                                },
                                                onFetchNotes: { student in
                                                    await noteViewModel.fetchAllNotes(student)
                                                },
                                                onFetchActivities: { student in
                                                    await activityViewModel.fetchActivities(student)
                                                },
                                                onCheckNickname: { nickname, currentStudentId in
                                                    studentViewModel.students.contains { student in
                                                        if let currentId = currentStudentId {
                                                            return student.nickname.lowercased() == nickname.lowercased() && student.id != currentId
                                                        }
                                                        return student.nickname.lowercased() == nickname.lowercased()
                                                    }
                                                },
                                                compressedImageData: studentViewModel.compressedImageData
                                            )
                                        } label: {
                                            ProfileCard(student: student) {
                                                Task {
                                                    await studentViewModel.deleteStudent(student)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, contentHorizontalPadding)
                            }
                            .simultaneousGesture(DragGesture().onChanged({ _ in
                                dismissKeyboard()
                            }))
                        }
                    }
                }
            }
            .background(backgroundColor)
            .navigationBarHidden(true)
        }
        .refreshable {
            await studentViewModel.fetchAllStudents()
        }
        .sheet(isPresented: $isAddingStudent) {
            ManageStudentView(
                mode: .add,
                compressedImageData: studentViewModel.compressedImageData,
                newStudentImage: studentViewModel.newStudentImage,
                onSave: { student in
                    await studentViewModel.addStudent(student)
                },
                onUpdate: { student in
                    await studentViewModel.updateStudent(student)
                },
                onImageChange: { image in
                    studentViewModel.newStudentImage = image
                },
                checkNickname: { nickname, currentStudentId in
                    studentViewModel.students.contains { student in
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
            await studentViewModel.fetchAllStudents()
        }
    }
    
    private var filteredStudents: [Student] {
        if searchQuery.isEmpty {
            return studentViewModel.students
        } else {
            return studentViewModel.students.filter { student in
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
