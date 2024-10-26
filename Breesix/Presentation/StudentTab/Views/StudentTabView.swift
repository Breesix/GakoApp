//
// StudentTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 29/09/24.
//

import SwiftUI
import Speech

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
                    .clipShape(.circle)
                    .overlay(
                        Circle()
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
                Color.bgMain
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissKeyboard()
                    }
                
                VStack (spacing: 0) {
                    CustomNavigationBar(title: "Murid") {
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
                                            StudentListCard(student: student) {
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
            StudentEditView(viewModel: viewModel, mode: .add)
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

struct CustomSearchBar: View {
    @Binding var text: String
    @State private var isEditing = false
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    var body: some View {
            HStack {
                TextField("Search", text: $text)
                    .padding(.horizontal, 33)
                    .padding(.vertical, 7)
                    .background(.fillTertiary)
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.labelSecondary)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            
                            if isRecording {
                                Button(action: {
                                    isRecording = false
                                    speechRecognizer.stopTranscribing()
                                }) {
                                    Image(systemName: "mic.fill.badge.xmark")
                                        .foregroundStyle(.red)
                                        .padding(.trailing, 8)
                                }
                            } else {
                                if text.isEmpty {
                                    Button(action: {
                                        isRecording = true
                                        speechRecognizer.startTranscribing()
                                    }) {
                                        Image(systemName: "mic.fill")
                                            .foregroundStyle(.labelSecondary)
                                            .padding(.trailing, 8)
                                    }
                                } else {
                                    Button(action: {
                                        self.text = ""
                                    }) {
                                        Image(systemName: "multiply.circle.fill")
                                            .foregroundStyle(.labelSecondary)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        withAnimation {
                            self.isEditing = true
                        }
                    }
            }
            .onAppear {
                requestSpeechAuthorization()
            }
            .onReceive(speechRecognizer.$transcript) { newTranscript in
                self.text = newTranscript
            }
        }

    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil,
                                      from: nil,
                                      for: nil)
    }
    
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                case .denied:
                    print("Speech recognition denied")
                case .restricted:
                    print("Speech recognition restricted")
                case .notDetermined:
                    print("Speech recognition not determined")
                @unknown default:
                    print("Unknown status")
                }
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
