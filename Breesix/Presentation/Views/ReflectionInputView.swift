//
//  ReflectionInputView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI
import Speech
struct ReflectionInputView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @ObservedObject var speechRecognizer: SpeechRecognizer
    @Environment(\.presentationMode) var presentationMode
    @State private var reflection: String = ""
    @State private var isLoading: Bool = false
    @State private var isRecord: Bool = false
    @State private var errorMessage: String?
    @Binding var isAllStudentsFilled: Bool
    @State private var alertMessage = ""
    @State private var showingAlert = false
    var inputType: InputType
    let selectedDate: Date  // Ensure this is Date
    var onDismiss: () -> Void
    private let reflectionProcessor = ReflectionProcessor(apiToken: "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")
    private let ttProcessor = AITTService(apiToken: "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")

    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                ZStack(alignment: .center) {
                    TextEditor(text: $reflection)
                        .padding()
                        .border(Color.gray, width: 1)

                    if reflection.isEmpty {
                        Text("Please enter your reflection here")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    if isLoading {
                        ProgressView()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                .padding()

                if inputType == .speech {
                    if !isRecord {
                        Button(action: {
                            self.speechRecognizer.startTranscribing()
                            isRecord.toggle()
                        }) {
                            Image("play-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                    } else {
                        Button(action: {
                            self.speechRecognizer.stopTranscribing()
                            self.reflection = self.speechRecognizer.transcript
                            isRecord.toggle()
                        }) {
                            Image("stop-mic-button")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60)
                        }
                    }
                }

                Button("Next") {
                    processReflection()
                    processReflectionToilet()
                }
                .padding()
                .disabled(reflection.isEmpty || isLoading)
            }
            .navigationTitle("Reflection Input")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onReceive(speechRecognizer.$transcript) { newTranscript in
            self.reflection = newTranscript
        }
    }
    
    private func processReflectionToilet() {
          Task {
              do {
                  isLoading = true
                  errorMessage = nil

                  await viewModel.loadStudents()

                  let csvString = try await ttProcessor.processReflection(reflection: reflection, students: viewModel.students)

                  let toiletTrainingList = TTCSVParser.parseActivities(csvString: csvString, students: viewModel.students, createdAt: selectedDate)

                  await MainActor.run {
                      isLoading = false

                      // Check if all students have toilet training data
                      let missingStudents = checkMissingData(toiletTrainingList: toiletTrainingList)

                      if missingStudents.isEmpty {
                          // If all students have data, update isAllStudentsFilled to true
                          isAllStudentsFilled = true
                          
                          viewModel.addUnsavedToiletTraining(toiletTrainingList)

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
      
       func checkMissingData(toiletTrainingList: [UnsavedToiletTraining]) -> [Student] {
          let studentsWithTraining = Set(toiletTrainingList.map { $0.studentId})
          let missingStudents = viewModel.students.filter { student in
              !studentsWithTraining.contains(student.id)
          }

          print("Total students: \(viewModel.students.count)")
          print("Total toilet trainings: \(toiletTrainingList.count)")
          print("Missing students: \(missingStudents.count)")

          return missingStudents
      }
  }

    private func processReflection() {
        Task {
            do {
                isLoading = true
                errorMessage = nil

                await viewModel.loadStudents()

                let csvString = try await reflectionProcessor.processReflection(reflection: reflection, students: viewModel.students)
                let unsavedActivities = CSVParser.parseUnsavedActivities(csvString: csvString, students: viewModel.students, createdAt: selectedDate)

                await MainActor.run {
                    isLoading = false
                    viewModel.addUnsavedActivities(unsavedActivities)
                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}



