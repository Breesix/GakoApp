//
//  ReflectionInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI


struct ReflectionInputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Binding var isShowingPreview: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let reflectionProcessor = ReflectionProcessor(apiToken: "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")
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $reflection)
                    .padding()
                    .border(Color.gray, width: 1)
                
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                
                Button("Next") {
                    processReflection()
                }
                .padding()
                .disabled(reflection.isEmpty || isLoading)
            }
            .navigationTitle("Curhat Manual")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func processReflection() {
        Task {
            do {
                isLoading = true
                errorMessage = nil
                
                await viewModel.loadStudents()
                
                let csvString = try await reflectionProcessor.processReflection(reflection: reflection, students: viewModel.students)
                
                let notes = CSVParser.parseNotes(csvString: csvString, students: viewModel.students)
                
                for note in notes {
                    await viewModel.addNote(note, for: note.student!)
                }
                
                await MainActor.run {
                    isLoading = false
                    presentationMode.wrappedValue.dismiss()
                    isShowingPreview = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    print("Error in processReflection: \(error)")
                }
            }
        }
    }
}
