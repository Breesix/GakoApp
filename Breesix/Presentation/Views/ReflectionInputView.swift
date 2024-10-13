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
    let selectedDate: Date
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
                    processReflectionNote()
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

                  await viewModel.fetchAllStudents()

                  let csvString = try await ttProcessor.processReflection(reflection: reflection, students: viewModel.students)

                  let toiletTrainingList = TTCSVParser.parseActivities(csvString: csvString, students: viewModel.students, createdAt: selectedDate)

                  await MainActor.run {
                      isLoading = false

                      let missingStudents = checkMissingData(toiletTrainingList: toiletTrainingList)

                      if missingStudents.isEmpty {
                          isAllStudentsFilled = true
                          
                          viewModel.addUnsavedToiletTraining(toiletTrainingList)

                          // Present the TrainingPreviewView if necessary
                          onDismiss()
  //                        if !isShowingTrainingPreview {
  //                            isShowingTrainingPreview = true
  //                        }
                      } else {
                          isAllStudentsFilled = false

                          alertMessage = "The following students are missing toilet training data: \(missingStudents.map { $0.fullname }.joined(separator: ", "))"
                          
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
      
       func checkMissingData(toiletTrainingList: [UnsavedActivity]) -> [Student] {
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

    private func processReflectionNote() {
        Task {
            do {
                isLoading = true
                errorMessage = nil

                await viewModel.fetchAllStudents()

                let csvString = try await reflectionProcessor.processReflection(reflection: reflection, students: viewModel.students)
                let unsavedNotes = CSVParser.parseUnsavedNotes(csvString: csvString, students: viewModel.students, createdAt: selectedDate)

                await MainActor.run {
                    isLoading = false
                    viewModel.addUnsavedNotes(unsavedNotes)
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



