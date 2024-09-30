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
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $reflection)
                    .padding()
                    .border(Color.gray, width: 1)
                
                Button("Next") {
                    processReflection()
                    presentationMode.wrappedValue.dismiss()
                    isShowingPreview = true
                }
                .padding()
                .disabled(reflection.isEmpty)
            }
            .navigationTitle("Curhat Manual")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func processReflection() {
        // Simulasi pemrosesan AI
        // pamggil API AI di sini
        for student in viewModel.students {
            let newNote = Note(
                generalActivity: "Aktivitas umum dari refleksi",
                toiletTraining: "Catatan toilet training dari refleksi",
                toiletTrainingStatus: Bool.random(),
                student: student
            )
            Task {
                await viewModel.addNote(newNote, for: student)
            }
        }
    }
}
