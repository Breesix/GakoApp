//
//  MandatoryInputView.swift
//  Breesix
//
//  Created by Akmal Hakim on 03/10/24.
//

import SwiftUI

struct MandatoryInputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Binding var isShowingTrainingPreview: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State var isFilledToday: Bool = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    @Binding var isAllStudentsFilled: Bool

    let selectedDate: Date
    var onDismiss: () -> Void

    private let ttProcessor = AITTService(apiToken: "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")

    var body: some View {
        NavigationView {
            VStack {
                if isFilledToday {
                    Text("You have filled this for today")
                        .foregroundColor(.green)
                } else {
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
            }
            .navigationTitle("Curhat Manual")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                resetIsFilledTodayIfNeeded()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Missing Data"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Function to reset isFilledToday daily
    func resetIsFilledTodayIfNeeded() {
        let lastResetDate = UserDefaults.standard.object(forKey: "lastResetDate") as? Date ?? Date.distantPast
        if !Calendar.current.isDateInToday(lastResetDate) {
            isFilledToday = false
            UserDefaults.standard.set(Date(), forKey: "lastResetDate")
        }
    }

    private func processReflection() {
        Task {
            do {
                isLoading = true
                errorMessage = nil

                await viewModel.loadStudents()

                let csvString = try await ttProcessor.processReflection(reflection: reflection, students: viewModel.students)

                let toiletTrainingList = TTCSVParser.parseActivities(csvString: csvString, students: viewModel.students)

                await MainActor.run {
                    isLoading = false

                    // Check if all students have toilet training data
                    let missingStudents = checkMissingData(toiletTrainingList: toiletTrainingList)

                    if missingStudents.isEmpty {
                        // If all students have data, update isAllStudentsFilled to true
                        isAllStudentsFilled = true
                        
                        viewModel.addToiletTraining(toiletTrainingList)

                        // Present the TrainingPreviewView if necessary
                        onDismiss()
//                        if !isShowingTrainingPreview {
//                            isShowingTrainingPreview = true
//                        }
                    } else {
                        // Otherwise, show an alert with the missing students
                        isAllStudentsFilled = false

                        // Set alert message before presenting the alert
                        alertMessage = "The following students are missing toilet training data: \(missingStudents.map { $0.fullname }.joined(separator: ", "))"
                        
                        // Present the alert on the main thread
                        Task {
                            await MainActor.run {
                                showingAlert = true
                            }
                        }
                    }
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

    private func checkMissingData(toiletTrainingList: [ToiletTraining]) -> [Student] {
        let studentsWithTraining = Set(toiletTrainingList.map { $0.student })
        let missingStudents = viewModel.students.filter { !studentsWithTraining.contains($0) }

        print("Total students: \(viewModel.students.count)")
        print("Total toilet trainings: \(toiletTrainingList.count)")
        print("Missing students: \(missingStudents.count)")

        return missingStudents
    }
}
